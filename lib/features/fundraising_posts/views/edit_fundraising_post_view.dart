import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import '../controllers/fundraising_posts_controller.dart';
import '../models/fundraising_post_model.dart';
import '../../revisions/controllers/revisions_controller.dart';
import 'package:investrack_admin/utils/constants.dart';
import 'package:investrack_admin/widgets/desktop_text_field.dart';
import 'widgets/post_comments_section.dart';

class EditFundraisingPostView extends StatefulWidget {
  final String id;
  const EditFundraisingPostView({super.key, required this.id});

  @override
  State<EditFundraisingPostView> createState() =>
      _EditFundraisingPostViewState();
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

  String _status = 'Active';
  bool _isUploading = false;
  late TextEditingController _adminFeedbackCtrl;
  late TextEditingController _contentCtrl;
  late TextEditingController _coverUrlCtrl;

  FundraisingPost? _originalPost;

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
    _contentCtrl = TextEditingController();
    _coverUrlCtrl = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final ctrl = context.read<FundraisingPostsController>();
    _originalPost = ctrl.posts.firstWhere((p) => p.id == widget.id);
    final post = _originalPost!;

    _titleCtrl.text = post.title;
    _excerptCtrl.text = post.excerpt;
    _roundTypeCtrl.text = post.roundType;
    _targetAmountCtrl.text = post.targetAmountUsd.toString();
    _minTicketCtrl.text = post.minTicketUsd.toString();
    _contactEmailCtrl.text = post.contactEmail;
    _pitchDeckUrlCtrl.text = post.pitchDeckUrl ?? '';
    _websiteUrlCtrl.text = post.websiteUrl ?? '';
    _deadlineCtrl.text = post.deadline.toIso8601String().split('T').first;
    _coverUrlCtrl.text = post.coverUrl ?? '';
    _status = post.status;
    _adminFeedbackCtrl.text = post.adminFeedback ?? '';

    try {
      if (post.content.isNotEmpty) {
        final decoded = jsonDecode(post.content);
        if (decoded is List) {
          final doc = quill.Document.fromJson(decoded);
          _contentCtrl.text = doc.toPlainText();
        } else {
          _contentCtrl.text = post.content;
        }
      }
    } catch (_) {
      _contentCtrl.text = post.content;
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
    _contentCtrl.dispose();
    _coverUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _isUploading = true;
        });
        if (!mounted) return;
        final ctrl = context.read<FundraisingPostsController>();
        final url = await ctrl.uploadCoverImage(bytes, image.name);
        if (url != null) {
          setState(() {
            _coverUrlCtrl.text = url;
          });
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to upload image')),
            );
          }
        }
        setState(() {
          _isUploading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  Map<String, dynamic> _getFormData() {
    return {
      'title': _titleCtrl.text,
      'excerpt': _excerptCtrl.text,
      'content': _contentCtrl.text,
      'round_type': _roundTypeCtrl.text,
      'target_amount_usd': double.tryParse(_targetAmountCtrl.text) ?? 0,
      'min_ticket_usd': double.tryParse(_minTicketCtrl.text) ?? 0,
      'contact_email': _contactEmailCtrl.text,
      'pitch_deck_url': _pitchDeckUrlCtrl.text,
      'website_url': _websiteUrlCtrl.text,
      'deadline':
          DateTime.tryParse(
            '${_deadlineCtrl.text}T00:00:00Z',
          )?.toIso8601String() ??
          DateTime.now().toUtc().toIso8601String(),
      'cover_url': _coverUrlCtrl.text,
    };
  }

  bool get _hasChanges {
    if (_originalPost == null) return false;
    final currentDeadline = DateTime.tryParse(_deadlineCtrl.text);
    final isDeadlineChanged =
        currentDeadline != null &&
        (_originalPost!.deadline.year != currentDeadline.year ||
            _originalPost!.deadline.month != currentDeadline.month ||
            _originalPost!.deadline.day != currentDeadline.day);

    return _titleCtrl.text != _originalPost!.title ||
        _excerptCtrl.text != _originalPost!.excerpt ||
        _contentCtrl.text != _originalPost!.content ||
        _roundTypeCtrl.text != _originalPost!.roundType ||
        _coverUrlCtrl.text != (_originalPost!.coverUrl ?? '') ||
        _websiteUrlCtrl.text != (_originalPost!.websiteUrl ?? '') ||
        _pitchDeckUrlCtrl.text != (_originalPost!.pitchDeckUrl ?? '') ||
        _contactEmailCtrl.text != _originalPost!.contactEmail ||
        (double.tryParse(_targetAmountCtrl.text) ?? 0) !=
            _originalPost!.targetAmountUsd ||
        (double.tryParse(_minTicketCtrl.text) ?? 0) !=
            _originalPost!.minTicketUsd ||
        isDeadlineChanged ||
        _status != _originalPost!.status ||
        _adminFeedbackCtrl.text != (_originalPost!.adminFeedback ?? '');
  }

  void _proposeEditToModeration() async {
    if (!_hasChanges) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No changes detected.')));
      return;
    }
    if (_formKey.currentState!.validate()) {
      final ctrl = context.read<FundraisingPostsController>();
      final revCtrl = context.read<RevisionsController>();

      final data = _getFormData();
      data['status'] = _status;
      if (_status == 'Hidden') {
        data['admin_feedback'] = _adminFeedbackCtrl.text;
      }

      final success = await ctrl.requestUpdatePost(revCtrl, widget.id, data);

      if (!success || !mounted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                revCtrl.errorMessage ?? 'Failed to propose edit to moderation',
              ),
            ),
          );
        }
        return;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Edit proposed to Moderation Queue!')),
        );
        context.pop();
      }
    }
  }

  void _sendFeedbackToFounder() async {
    if (!_hasChanges && _status == 'Hidden') {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No changes detected.')));
      return;
    }
    if (_adminFeedbackCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter Admin Feedback first (Status will be set to Hidden).',
          ),
        ),
      );
      return;
    }

    final ctrl = context.read<FundraisingPostsController>();

    final success = await ctrl.updatePostStatus(
      widget.id,
      'Hidden',
      adminFeedback: _adminFeedbackCtrl.text.trim(),
    );

    if (!success || !mounted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ctrl.errorMessage ?? 'Failed to send feedback'),
          ),
        );
      }
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feedback sent! Post is now Hidden.')),
      );
      context.pop();
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
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Cover Image
                      const Text(
                        'Cover Image URL',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: DesktopTextFormField(
                              controller: _coverUrlCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Image URL (or upload)',
                                prefixIcon: Icon(Icons.link),
                              ),
                              onChanged: (val) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: _isUploading
                                  ? null
                                  : _pickAndUploadImage,
                              icon: _isUploading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.upload),
                              label: const Text('Upload'),
                            ),
                          ),
                        ],
                      ),
                      if (_coverUrlCtrl.text.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                            image: DecorationImage(
                              image: NetworkImage(_coverUrlCtrl.text),
                              fit: BoxFit.cover,
                              onError: (e, s) {},
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: DesktopTextFormField(
                              controller: _titleCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Title',
                                prefixIcon: Icon(Icons.title),
                              ),
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
                              items:
                                  ['Active', 'Expired', 'Cancelled', 'Hidden']
                                      .map(
                                        (s) => DropdownMenuItem(
                                          value: s,
                                          child: Text(s),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (v) => setState(() => _status = v!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DesktopTextFormField(
                        controller: _excerptCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Excerpt',
                          prefixIcon: Icon(Icons.short_text),
                        ),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 24),

                      // Content Editor
                      const Text(
                        'Content',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DesktopTextFormField(
                        controller: _contentCtrl,
                        maxLines: 15,
                        minLines: 8,
                        keyboardType: TextInputType.multiline,
                        decoration: const InputDecoration(
                          hintText:
                              'Tell investors why they should invest, your traction, and how you will use the funds...',
                          alignLabelWithHint: true,
                        ),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 24),

                      const Text(
                        'Round Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DesktopTextFormField(
                              controller: _roundTypeCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Round Type',
                                prefixIcon: Icon(Icons.category),
                              ),
                              validator: (v) => v!.isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DesktopTextFormField(
                              controller: _targetAmountCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Target Amount (USD)',
                                prefixIcon: Icon(Icons.attach_money),
                              ),
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
                              decoration: const InputDecoration(
                                labelText: 'Minimum Ticket (USD)',
                                prefixIcon: Icon(Icons.local_activity),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (v) => v!.isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DesktopTextFormField(
                              controller: _deadlineCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Deadline (YYYY-MM-DD)',
                                prefixIcon: Icon(Icons.calendar_today),
                              ),
                              validator: (v) => v!.isEmpty ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      const Text(
                        'Contact & Links',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DesktopTextFormField(
                              controller: _contactEmailCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Contact Email',
                                prefixIcon: Icon(Icons.email),
                              ),
                              validator: (v) => v!.isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DesktopTextFormField(
                              controller: _websiteUrlCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Website URL',
                                prefixIcon: Icon(Icons.language),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      DesktopTextFormField(
                        controller: _pitchDeckUrlCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Pitch Deck URL',
                          prefixIcon: Icon(Icons.picture_as_pdf),
                        ),
                      ),
                      const SizedBox(height: 32),

                      const Text(
                        'Manage Comments',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(12),
                          color: Theme.of(context).cardColor,
                        ),
                        child: PostCommentsSection(postId: widget.id),
                      ),
                      const SizedBox(height: 32),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.1),
                          border: Border.all(color: AppColors.warning),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.feedback,
                                  color: AppColors.warning,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Feedback / Moderation Action',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.warning.withAlpha(200),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            DesktopTextFormField(
                              controller: _adminFeedbackCtrl,
                              maxLines: 2,
                              decoration: const InputDecoration(
                                labelText:
                                    'Admin Feedback (Required for Send Feedback action)',
                                alignLabelWithHint: true,
                                filled: true,
                                fillColor: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 48,
                                    child: OutlinedButton.icon(
                                      onPressed: _proposeEditToModeration,
                                      icon: const Icon(Icons.rate_review),
                                      label: const Text(
                                        'Propose Edit to Moderation',
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: SizedBox(
                                    height: 48,
                                    child: ElevatedButton.icon(
                                      onPressed: _sendFeedbackToFounder,
                                      icon: const Icon(Icons.send),
                                      label: const Text(
                                        'Send Feedback to Founder',
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.warning,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
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
