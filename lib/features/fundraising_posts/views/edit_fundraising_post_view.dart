import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import '../controllers/fundraising_posts_controller.dart';
import 'package:investrack_admin/utils/constants.dart';
import 'package:investrack_admin/widgets/desktop_text_field.dart';

class EditFundraisingPostView extends StatefulWidget {
  final String id;
  const EditFundraisingPostView({super.key, required this.id});

  @override
  State<EditFundraisingPostView> createState() => _EditFundraisingPostViewState();
}

class _EditFundraisingPostViewState extends State<EditFundraisingPostView> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _titleCtrl;
  late TextEditingController _excerptCtrl;
  late TextEditingController _roundTypeCtrl;
  late TextEditingController _targetAmountCtrl;
  late TextEditingController _minTicketCtrl;
  late TextEditingController _contactEmailCtrl;
  late TextEditingController _pitchDeckUrlCtrl;
  late TextEditingController _websiteUrlCtrl;
  late TextEditingController _deadlineCtrl;
  
  String? _coverUrl;
  String _status = 'Active';
  bool _isUploading = false;
  late TextEditingController _adminFeedbackCtrl;
  
  late quill.QuillController _quillController;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController();
    _excerptCtrl = TextEditingController();
    _roundTypeCtrl = TextEditingController();
    _targetAmountCtrl = TextEditingController();
    _minTicketCtrl = TextEditingController();
    _contactEmailCtrl = TextEditingController();
    _pitchDeckUrlCtrl = TextEditingController();
    _websiteUrlCtrl = TextEditingController();
    _deadlineCtrl = TextEditingController();
    _adminFeedbackCtrl = TextEditingController();
    
    _quillController = quill.QuillController.basic();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final ctrl = context.read<FundraisingPostsController>();
    final post = ctrl.posts.firstWhere((p) => p.id == widget.id);
    
    _titleCtrl.text = post.title;
    _excerptCtrl.text = post.excerpt;
    _roundTypeCtrl.text = post.roundType;
    _targetAmountCtrl.text = post.targetAmountUsd.toString();
    _minTicketCtrl.text = post.minTicketUsd.toString();
    _contactEmailCtrl.text = post.contactEmail;
    _pitchDeckUrlCtrl.text = post.pitchDeckUrl ?? '';
    _websiteUrlCtrl.text = post.websiteUrl ?? '';
    _deadlineCtrl.text = post.deadline.toIso8601String().split('T').first;
    _coverUrl = post.coverUrl;
    _status = post.status;
    _adminFeedbackCtrl.text = post.adminFeedback ?? '';
    
    try {
      if (post.content.isNotEmpty) {
        final doc = quill.Document.fromJson(jsonDecode(post.content));
        _quillController = quill.QuillController(
          document: doc,
          selection: const TextSelection.collapsed(offset: 0),
        );
      }
    } catch (e) {
      // If it fails to parse as JSON (maybe it's plain text), just insert text
      _quillController.document.insert(0, post.content);
    }
    setState(() {});
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _excerptCtrl.dispose();
    _roundTypeCtrl.dispose();
    _targetAmountCtrl.dispose();
    _minTicketCtrl.dispose();
    _contactEmailCtrl.dispose();
    _pitchDeckUrlCtrl.dispose();
    _websiteUrlCtrl.dispose();
    _deadlineCtrl.dispose();
    _adminFeedbackCtrl.dispose();
    _quillController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() { _isUploading = true; });
      if (!mounted) return;
      final ctrl = context.read<FundraisingPostsController>();
      final url = await ctrl.uploadCoverImage(bytes, image.name);
      if (url != null) {
        setState(() { _coverUrl = url; });
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to upload image')));
      }
      setState(() { _isUploading = false; });
    }
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      final ctrl = context.read<FundraisingPostsController>();
      
      final contentJson = jsonEncode(_quillController.document.toDelta().toJson());
      
      final data = {
        'title': _titleCtrl.text,
        'excerpt': _excerptCtrl.text,
        'content': contentJson,
        'roundType': _roundTypeCtrl.text,
        'targetAmountUsd': double.tryParse(_targetAmountCtrl.text) ?? 0,
        'minTicketUsd': double.tryParse(_minTicketCtrl.text) ?? 0,
        'contactEmail': _contactEmailCtrl.text,
        'pitchDeckUrl': _pitchDeckUrlCtrl.text,
        'websiteUrl': _websiteUrlCtrl.text,
        'deadline': DateTime.tryParse(_deadlineCtrl.text)?.toIso8601String() ?? DateTime.now().toIso8601String(),
        'coverUrl': _coverUrl,
      };

      final success = await ctrl.updatePost(widget.id, data);
      
      if (!success || !mounted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ctrl.errorMessage ?? 'Failed to update post')));
        }
        return;
      }

      final post = ctrl.posts.firstWhere((p) => p.id == widget.id);
      bool statusSuccess = true;
      if (post.status != _status || (_status == 'Hidden' && post.adminFeedback != _adminFeedbackCtrl.text)) {
        statusSuccess = await ctrl.updatePostStatus(widget.id, _status, adminFeedback: _status == 'Hidden' ? _adminFeedbackCtrl.text : null);
      }

      if (statusSuccess && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post updated successfully')));
        context.pop();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ctrl.errorMessage ?? 'Failed to update post status')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Fundraising Post'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Post Information',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 16),
                      // Cover Image
                      const Text('Cover Image', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _pickAndUploadImage,
                        child: Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                            image: _coverUrl != null && _coverUrl!.isNotEmpty
                                ? DecorationImage(image: NetworkImage(_coverUrl!), fit: BoxFit.cover)
                                : null,
                          ),
                          child: _isUploading
                              ? const Center(child: CircularProgressIndicator())
                              : (_coverUrl == null || _coverUrl!.isEmpty)
                                  ? Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        Icon(Icons.cloud_upload, size: 48, color: AppColors.textMuted),
                                        SizedBox(height: 8),
                                        Text('Click to upload cover image', style: TextStyle(color: AppColors.textSecondary)),
                                      ],
                                    )
                                  : null,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: DesktopTextFormField(
                              controller: _titleCtrl,
                              decoration: const InputDecoration(labelText: 'Title', prefixIcon: Icon(Icons.title)),
                              validator: (v) => v!.isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _status,
                              decoration: const InputDecoration(
                                labelText: 'Status',
                                prefixIcon: Icon(Icons.flag),
                              ),
                              items: ['Active', 'Expired', 'Cancelled', 'Hidden'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                              onChanged: (v) => setState(() => _status = v!),
                            ),
                          ),
                        ],
                      ),
                      if (_status == 'Hidden') ...[
                        const SizedBox(height: 12),
                        DesktopTextFormField(
                          controller: _adminFeedbackCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Admin Feedback (Reason for hiding)',
                            prefixIcon: Icon(Icons.feedback),
                            alignLabelWithHint: true,
                          ),
                          validator: (v) => _status == 'Hidden' && v!.isEmpty ? 'Feedback is required when hiding a post' : null,
                        ),
                      ],
                      const SizedBox(height: 12),
                      DesktopTextFormField(
                        controller: _excerptCtrl,
                        decoration: const InputDecoration(labelText: 'Excerpt', prefixIcon: Icon(Icons.short_text)),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 24),

                      // Rich Text Editor
                      const Text('Content', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(12),
                          color: Theme.of(context).cardColor,
                        ),
                        child: Column(
                          children: [
                            Container(
                              height: 300,
                              padding: const EdgeInsets.all(16),
                              child: quill.QuillEditor.basic(
                                controller: _quillController,
                                configurations: const quill.QuillEditorConfigurations(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      const Text(
                        'Round Details',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DesktopTextFormField(
                              controller: _roundTypeCtrl,
                              decoration: const InputDecoration(labelText: 'Round Type', prefixIcon: Icon(Icons.category)),
                              validator: (v) => v!.isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DesktopTextFormField(
                              controller: _targetAmountCtrl,
                              decoration: const InputDecoration(labelText: 'Target Amount (USD)', prefixIcon: Icon(Icons.attach_money)),
                              keyboardType: TextInputType.number,
                              validator: (v) => v!.isEmpty ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: DesktopTextFormField(
                              controller: _minTicketCtrl,
                              decoration: const InputDecoration(labelText: 'Minimum Ticket (USD)', prefixIcon: Icon(Icons.local_activity)),
                              keyboardType: TextInputType.number,
                              validator: (v) => v!.isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DesktopTextFormField(
                              controller: _deadlineCtrl,
                              decoration: const InputDecoration(labelText: 'Deadline (YYYY-MM-DD)', prefixIcon: Icon(Icons.calendar_today)),
                              validator: (v) => v!.isEmpty ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      const Text(
                        'Contact & Links',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DesktopTextFormField(
                              controller: _contactEmailCtrl,
                              decoration: const InputDecoration(labelText: 'Contact Email', prefixIcon: Icon(Icons.email)),
                              validator: (v) => v!.isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DesktopTextFormField(
                              controller: _websiteUrlCtrl,
                              decoration: const InputDecoration(labelText: 'Website URL', prefixIcon: Icon(Icons.language)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      DesktopTextFormField(
                        controller: _pitchDeckUrlCtrl,
                        decoration: const InputDecoration(labelText: 'Pitch Deck URL', prefixIcon: Icon(Icons.picture_as_pdf)),
                      ),
                      const SizedBox(height: 32),

                      SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _save,
                          icon: const Icon(Icons.save),
                          label: const Text('Update Post'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
