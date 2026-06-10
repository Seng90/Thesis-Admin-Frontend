import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/fundraising_post_model.dart';
import '../controllers/fundraising_posts_controller.dart';
import 'package:investrack_admin/utils/constants.dart';
import 'package:investrack_admin/utils/localizations.dart';

class FundraisingPostDetailsView extends StatefulWidget {
  final String slug;

  const FundraisingPostDetailsView({super.key, required this.slug});

  @override
  State<FundraisingPostDetailsView> createState() => _FundraisingPostDetailsViewState();
}

class _FundraisingPostDetailsViewState extends State<FundraisingPostDetailsView> {
  FundraisingPost? _post;
  quill.QuillController? _quillController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPost();
    });
  }

  Future<void> _loadPost() async {
    final ctrl = context.read<FundraisingPostsController>();
    final post = await ctrl.getPostBySlug(widget.slug);
    
    if (mounted) {
      setState(() {
        _post = post;
        _isLoading = false;
        
        if (post != null && post.content.isNotEmpty) {
          try {
            final doc = quill.Document.fromJson(jsonDecode(post.content));
            _quillController = quill.QuillController(
              document: doc,
              selection: const TextSelection.collapsed(offset: 0),
            );
          } catch (e) {
            final doc = quill.Document()..insert(0, post.content);
            _quillController = quill.QuillController(
              document: doc,
              selection: const TextSelection.collapsed(offset: 0),
            );
          }
        }
      });
    }
  }

  Future<void> _launchUrl(String? urlString) async {
    if (urlString == null || urlString.isEmpty) return;
    final url = Uri.tryParse(urlString);
    if (url != null && await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not launch URL')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Loading Details...'.tr(context))),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_post == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Post Not Found'.tr(context))),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              const Text('Could not find the requested fundraising post.', style: TextStyle(fontSize: 18, color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/raises'),
                child: const Text('Back to List'),
              ),
            ],
          ),
        ),
      );
    }

    final currencyFormatter = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    final dateFormatter = DateFormat('MMMM dd, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text('Fundraising Details'.tr(context)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/raises'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Card
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_post!.coverUrl != null && _post!.coverUrl!.isNotEmpty)
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              image: DecorationImage(
                                image: NetworkImage(_post!.coverUrl!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        else
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                _post!.title.substring(0, 1).toUpperCase(),
                                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                            ),
                          ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      _post!.title,
                                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _post!.status == 'Active' ? AppColors.successBg : (_post!.status == 'Hidden' ? AppColors.warningBg : AppColors.textMuted.withValues(alpha: 0.1)),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      _post!.status.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: _post!.status == 'Active' ? AppColors.success : (_post!.status == 'Hidden' ? AppColors.warning : AppColors.textMuted),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _post!.excerpt,
                                style: const TextStyle(fontSize: 16, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                              ),
                              if (_post!.status == 'Hidden' && _post!.adminFeedback != null && _post!.adminFeedback!.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.warningBg,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.warning.withValues(alpha: 0.5)),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.info_outline, color: AppColors.warning, size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Admin Feedback (Hidden Reason)', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.warning)),
                                            const SizedBox(height: 4),
                                            Text(_post!.adminFeedback!, style: const TextStyle(color: AppColors.textPrimary)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () => context.push('/raises/edit/${_post!.id}'),
                                    icon: const Icon(Icons.edit, size: 16),
                                    label: const Text('Edit Post'),
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  if (_post!.websiteUrl != null && _post!.websiteUrl!.isNotEmpty)
                                    OutlinedButton.icon(
                                      onPressed: () => _launchUrl(_post!.websiteUrl),
                                      icon: const Icon(Icons.open_in_new, size: 16),
                                      label: const Text('Website'),
                                      style: OutlinedButton.styleFrom(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                    ),
                                  const SizedBox(width: 12),
                                  if (_post!.pitchDeckUrl != null && _post!.pitchDeckUrl!.isNotEmpty)
                                    OutlinedButton.icon(
                                      onPressed: () => _launchUrl(_post!.pitchDeckUrl),
                                      icon: const Icon(Icons.picture_as_pdf, size: 16),
                                      label: const Text('Pitch Deck'),
                                      style: OutlinedButton.styleFrom(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                const SizedBox(height: 24),
                // Details Cards
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: AppColors.border),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Pitch Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 16),
                              if (_quillController != null)
                                quill.QuillEditor.basic(
                                  controller: _quillController!,
                                  configurations: const quill.QuillEditorConfigurations(),
                                )
                              else
                                const Text('No content available.', style: TextStyle(color: AppColors.textMuted)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 1,
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: AppColors.border),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Round Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 24),
                              _buildGlanceItem('Round Type', _post!.roundType, Icons.category_outlined),
                              const Divider(height: 32),
                              _buildGlanceItem('Target', currencyFormatter.format(_post!.targetAmountUsd), Icons.attach_money_outlined),
                              const Divider(height: 32),
                              _buildGlanceItem('Min Ticket', currencyFormatter.format(_post!.minTicketUsd), Icons.local_activity_outlined),
                              const Divider(height: 32),
                              _buildGlanceItem('Deadline', dateFormatter.format(_post!.deadline), Icons.calendar_today_outlined),
                              const Divider(height: 32),
                              _buildGlanceItem('Email', _post!.contactEmail, Icons.email_outlined),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlanceItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}
