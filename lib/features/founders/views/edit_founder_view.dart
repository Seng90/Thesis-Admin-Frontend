import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:investrack_admin/features/founders/controllers/founders_controller.dart';
import 'package:investrack_admin/features/founders/models/founder_model.dart';
import 'package:investrack_admin/features/revisions/controllers/revisions_controller.dart';
import 'package:investrack_admin/features/companies/controllers/companies_controller.dart';
import 'package:investrack_admin/features/companies/models/company_model.dart';
import 'package:investrack_admin/utils/constants.dart';

class EditFounderView extends StatefulWidget {
  final String founderId;

  const EditFounderView({super.key, required this.founderId});

  @override
  State<EditFounderView> createState() => _EditFounderViewState();
}

class _EditFounderViewState extends State<EditFounderView> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameEnController;
  late TextEditingController _nameLaController;
  late TextEditingController _bioController;
  late TextEditingController _linkedinController;
  late TextEditingController _skillsController;
  late TextEditingController _pastExperienceController;
  late TextEditingController _twitterController;
  late TextEditingController _githubController;
  late TextEditingController _avatarUrlController;

  Founder? _existingFounder;
  bool _isSaving = false;
  bool _isInit = false;
  List<String> _selectedCompanyIds = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final controller = Provider.of<FoundersController>(
        context,
        listen: false,
      );
      try {
        _existingFounder = controller.founders.firstWhere(
          (f) => f.id == widget.founderId,
        );
      } catch (_) {
        _existingFounder = null;
      }

      _nameEnController = TextEditingController(
        text: _existingFounder?.nameEn ?? '',
      );
      _nameLaController = TextEditingController(
        text: _existingFounder?.nameLa ?? '',
      );
      _bioController = TextEditingController(text: _existingFounder?.bio ?? '');
      _linkedinController = TextEditingController(
        text: _existingFounder?.linkedinUrl ?? '',
      );
      _skillsController = TextEditingController(
        text: _existingFounder?.skills?.join(', ') ?? '',
      );
      _pastExperienceController = TextEditingController(
        text: _existingFounder?.pastExperience ?? '',
      );
      _twitterController = TextEditingController(
        text: _existingFounder?.twitterUrl ?? '',
      );
      _githubController = TextEditingController(
        text: _existingFounder?.githubUrl ?? '',
      );
      _avatarUrlController = TextEditingController(
        text: _existingFounder?.avatarUrl ?? '',
      );
      
      _selectedCompanyIds = _existingFounder?.companies.map((c) => c.id).toList() ?? [];

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final companiesController = Provider.of<CompaniesController>(
          context,
          listen: false,
        );
        if (companiesController.companies.isEmpty) {
          companiesController.loadCompanies();
        }
      });

      _isInit = true;
    }
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

    final revController = Provider.of<RevisionsController>(
      context,
      listen: false,
    );

    final proposedChanges = <String, dynamic>{};
    if (_nameEnController.text.trim() != _existingFounder?.nameEn) {
      proposedChanges['name_en'] = _nameEnController.text.trim();
    }
    if (_nameLaController.text.trim() != _existingFounder?.nameLa) {
      proposedChanges['name_la'] = _nameLaController.text.trim();
    }
    if (_bioController.text.trim() != _existingFounder?.bio) {
      proposedChanges['bio'] = _bioController.text.trim();
    }
    if (_linkedinController.text.trim() != _existingFounder?.linkedinUrl) {
      proposedChanges['linkedin_url'] = _linkedinController.text.trim();
    }
    if (_pastExperienceController.text.trim() !=
        _existingFounder?.pastExperience) {
      proposedChanges['past_experience'] = _pastExperienceController.text
          .trim();
    }
    if (_twitterController.text.trim() != _existingFounder?.twitterUrl) {
      proposedChanges['twitter_url'] = _twitterController.text.trim();
    }
    if (_githubController.text.trim() != _existingFounder?.githubUrl) {
      proposedChanges['github_url'] = _githubController.text.trim();
    }
    if (_avatarUrlController.text.trim() != _existingFounder?.avatarUrl) {
      proposedChanges['avatar_url'] = _avatarUrlController.text.trim();
    }

    final newSkills = _skillsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (newSkills.join(',') != (_existingFounder?.skills?.join(',') ?? '')) {
      proposedChanges['skills'] = newSkills;
    }

    final existingCompanyIds = _existingFounder?.companies.map((c) => c.id).toList() ?? [];
    if (_selectedCompanyIds.length != existingCompanyIds.length || !_selectedCompanyIds.every((id) => existingCompanyIds.contains(id))) {
      proposedChanges['companyIds'] = _selectedCompanyIds;
    }

    if (proposedChanges.isEmpty) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No changes made.')));
      context.pop();
      return;
    }

    final success = await revController.createRevision(
      entityType: 'Founder',
      entityId: widget.founderId,
      proposedChanges: proposedChanges,
    );

    if (mounted) {
      setState(() => _isSaving = false);

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              revController.errorMessage ?? 'Failed to submit revision',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Edit submitted for review!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_existingFounder == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Founder')),
        body: const Center(child: Text('Founder not found.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Founder'),
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
                        'Founder Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameLaController,
                        decoration: const InputDecoration(
                          labelText: 'Founder Name (Lao) *',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (v) =>
                            v!.trim().isEmpty ? 'Lao name is required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _nameEnController,
                        decoration: const InputDecoration(
                          labelText: 'Founder Name (English) *',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (v) => v!.trim().isEmpty
                            ? 'English name is required'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _bioController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Bio',
                          prefixIcon: Icon(Icons.description),
                          alignLabelWithHint: true,
                        ),
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
                      const Text(
                        'Additional Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _linkedinController,
                        decoration: const InputDecoration(
                          labelText: 'LinkedIn URL',
                          prefixIcon: Icon(Icons.link),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _skillsController,
                        decoration: const InputDecoration(
                          labelText: 'Skills (comma-separated)',
                          prefixIcon: Icon(Icons.build),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _pastExperienceController,
                        decoration: const InputDecoration(
                          labelText: 'Past Experience',
                          prefixIcon: Icon(Icons.work),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _twitterController,
                        decoration: const InputDecoration(
                          labelText: 'Twitter URL',
                          prefixIcon: Icon(Icons.link),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _githubController,
                        decoration: const InputDecoration(
                          labelText: 'GitHub URL',
                          prefixIcon: Icon(Icons.link),
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
                        child: ElevatedButton.icon(
                          onPressed: _isSaving ? null : _saveForm,
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.save),
                          label: Text(
                            _isSaving ? 'Updating...' : 'Update Founder',
                          ),
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
