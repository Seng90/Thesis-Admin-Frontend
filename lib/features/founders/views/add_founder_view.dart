import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:investrack_admin/features/founders/controllers/founders_controller.dart';
import 'package:investrack_admin/features/revisions/controllers/revisions_controller.dart';
import 'package:investrack_admin/features/companies/controllers/companies_controller.dart';
import 'package:investrack_admin/features/companies/models/company_model.dart';
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
  final _avatarUrlController = TextEditingController();
  bool _isSaving = false;
  List<String> _selectedCompanyIds = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final companiesController = Provider.of<CompaniesController>(
        context,
        listen: false,
      );
      if (companiesController.companies.isEmpty) {
        companiesController.loadCompanies();
      }
    });
  }

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
    _avatarUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadAvatar() async {
    final picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => _isSaving = true);
        final bytes = await image.readAsBytes();
        final ctrl = Provider.of<FoundersController>(context, listen: false);
        final url = await ctrl.uploadFounderAvatar(bytes, image.name);
        setState(() => _isSaving = false);
        
        if (url != null) {
          _avatarUrlController.text = url;
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Avatar uploaded successfully')),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to upload avatar')),
            );
          }
        }
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
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
    if (_avatarUrlController.text.trim().isNotEmpty) {
      proposedChanges['avatar_url'] = _avatarUrlController.text.trim();
    }
    
    if (_selectedCompanyIds.isNotEmpty) {
      proposedChanges['companyIds'] = _selectedCompanyIds;
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
                      Consumer<CompaniesController>(
                        builder: (context, companiesController, child) {
                          if (companiesController.isLoading) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Founded Companies',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () => _showCompanySelectDialog(companiesController.companies),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.border),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _selectedCompanyIds.isEmpty
                                            ? 'Select companies'
                                            : '${_selectedCompanyIds.length} companies selected',
                                        style: TextStyle(
                                          color: _selectedCompanyIds.isEmpty
                                              ? AppColors.textMuted
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                      const Icon(Icons.arrow_drop_down, color: AppColors.textMuted),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
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
                      const SizedBox(height: 16),
                      Container(
                        height: 56, // Matches standard TextFormField height
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            const Icon(Icons.image, color: AppColors.textSecondary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _avatarUrlController.text.isNotEmpty
                                    ? 'Avatar uploaded'
                                    : 'No avatar selected',
                                style: TextStyle(
                                  color: _avatarUrlController.text.isNotEmpty
                                      ? AppColors.success
                                      : AppColors.textSecondary,
                                  fontWeight: _avatarUrlController.text.isNotEmpty ? FontWeight.bold : FontWeight.normal,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: _isSaving ? null : _pickAndUploadAvatar,
                              icon: const Icon(Icons.upload_file, size: 18),
                              label: const Text('Upload'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                              ),
                            ),
                          ],
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

  void _showCompanySelectDialog(List<Company> availableCompanies) {
    List<String> tempSelected = List.from(_selectedCompanyIds);
    String searchQuery = '';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final filteredCompanies = availableCompanies.where((c) {
              return c.name.toLowerCase().contains(searchQuery.toLowerCase());
            }).toList();

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: const Text('Select Founded Companies'),
              content: SizedBox(
                width: 400,
                height: 400,
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search companies...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      onChanged: (val) {
                        setDialogState(() {
                          searchQuery = val;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredCompanies.length,
                        itemBuilder: (context, index) {
                          final company = filteredCompanies[index];
                          final isSelected = tempSelected.contains(company.id);
                          return CheckboxListTile(
                            title: Text(company.name),
                            subtitle: Text(
                              company.industry,
                              style: const TextStyle(fontSize: 12),
                            ),
                            value: isSelected,
                            onChanged: (bool? value) {
                              setDialogState(() {
                                if (value == true) {
                                  tempSelected.add(company.id);
                                } else {
                                  tempSelected.remove(company.id);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedCompanyIds = tempSelected;
                    });
                    context.pop();
                  },
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
