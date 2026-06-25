import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:investrack_admin/features/revisions/controllers/revisions_controller.dart';
import 'package:investrack_admin/utils/constants.dart';

class AddFounderView extends StatefulWidget {
  const AddFounderView({super.key});

  @override
  State<AddFounderView> createState() => _AddFounderViewState();
}

class _AddFounderViewState extends State<AddFounderView> {
  final _formKey = GlobalKey<FormState>();
  final _nameEnController = TextEditingController();
  final _nameLaController = TextEditingController();
  final _bioController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _skillsController = TextEditingController();
  final _pastExperienceController = TextEditingController();
  final _twitterController = TextEditingController();
  final _githubController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameEnController.dispose();
    _nameLaController.dispose();
    _bioController.dispose();
    _linkedinController.dispose();
    _skillsController.dispose();
    _pastExperienceController.dispose();
    _twitterController.dispose();
    _githubController.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final revisionsController = Provider.of<RevisionsController>(
      context,
      listen: false,
    );

    Map<String, dynamic> proposedChanges = {
      'name_en': _nameEnController.text.trim(),
      'name_la': _nameLaController.text.trim(),
    };

    if (_bioController.text.trim().isNotEmpty) {
      proposedChanges['bio'] = _bioController.text.trim();
    }
    if (_linkedinController.text.trim().isNotEmpty) {
      proposedChanges['linkedin_url'] = _linkedinController.text.trim();
    }
    if (_pastExperienceController.text.trim().isNotEmpty) {
      proposedChanges['past_experience'] = _pastExperienceController.text
          .trim();
    }
    if (_twitterController.text.trim().isNotEmpty) {
      proposedChanges['twitter_url'] = _twitterController.text.trim();
    }
    if (_githubController.text.trim().isNotEmpty) {
      proposedChanges['github_url'] = _githubController.text.trim();
    }
    if (_skillsController.text.trim().isNotEmpty) {
      proposedChanges['skills'] = _skillsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    final success = await revisionsController.createRevision(
      entityType: 'Founder',
      entityId: null,
      proposedChanges: proposedChanges,
    );

    if (mounted) {
      setState(() => _isSaving = false);

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              revisionsController.errorMessage ?? 'Failed to submit revision',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Founder creation submitted for review!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Founder'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nameLaController,
                        decoration: const InputDecoration(
                          labelText: 'Founder Name (Lao) *',
                        ),
                        validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameEnController,
                        decoration: const InputDecoration(
                          labelText: 'Founder Name (English) *',
                        ),
                        validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _bioController,
                        decoration: const InputDecoration(labelText: 'Bio'),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _linkedinController,
                        decoration: const InputDecoration(
                          labelText: 'LinkedIn URL',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _skillsController,
                        decoration: const InputDecoration(
                          labelText: 'Skills (comma-separated)',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _pastExperienceController,
                        decoration: const InputDecoration(
                          labelText: 'Past Experience',
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _twitterController,
                        decoration: const InputDecoration(
                          labelText: 'Twitter URL',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _githubController,
                        decoration: const InputDecoration(
                          labelText: 'GitHub URL',
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveForm,
                          child: _isSaving
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Save Founder'),
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
