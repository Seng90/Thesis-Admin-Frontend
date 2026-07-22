import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:investrack_admin/features/investors/controllers/investors_controller.dart';
import 'package:investrack_admin/features/investors/models/investor_model.dart';
import 'package:investrack_admin/features/revisions/controllers/revisions_controller.dart';
import 'package:investrack_admin/utils/constants.dart';
import 'package:investrack_admin/utils/localizations.dart';
import 'package:investrack_admin/widgets/editable_multi_select_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditInvestorView extends StatefulWidget {
  final String investorId;

  const EditInvestorView({super.key, required this.investorId});

  @override
  State<EditInvestorView> createState() => _EditInvestorViewState();
}

class _EditInvestorViewState extends State<EditInvestorView> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _websiteController;
  late TextEditingController _contactController;
  late TextEditingController _logoUrlController;
  late TextEditingController _focusController;
  List<String> _selectedStages = [];
  List<String> _selectedIndustries = [];
  String? _type;
  List<String> _types = [
    'VC',
    'Angel',
    'PE',
    'Corporate',
    'Accelerator',
    'Syndicate',
    'Other',
  ];

  bool _isSaving = false;
  bool _isInit = false;
  Investor? _existingInvestor;

  @override
  void initState() {
    super.initState();
    _loadTypes();
  }

  Future<void> _loadTypes() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('admin_investor_types');
    if (saved != null && saved.isNotEmpty) {
      if (mounted) {
        setState(() {
          _types = saved;
        });
      }
    }
  }

  Future<void> _saveTypes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('admin_investor_types', _types);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final controller = Provider.of<InvestorsController>(
        context,
        listen: false,
      );
      try {
        _existingInvestor = controller.investors.firstWhere(
          (i) => i.id == widget.investorId,
        );
      } catch (_) {
        _existingInvestor = null;
      }

      _nameController = TextEditingController(
        text: _existingInvestor?.name ?? '',
      );
      _websiteController = TextEditingController(
        text: _existingInvestor?.websiteUrl ?? '',
      );
      _contactController = TextEditingController(
        text: _existingInvestor?.contactInfo ?? '',
      );
      _logoUrlController = TextEditingController(
        text: _existingInvestor?.logoUrl ?? '',
      );
      _focusController = TextEditingController(
        text: _existingInvestor?.investmentFocus ?? '',
      );
      _selectedStages = List<String>.from(_existingInvestor?.preferredStages ?? []);
      _selectedIndustries = List<String>.from(_existingInvestor?.preferredIndustries ?? []);

      String initialType = _existingInvestor?.type ?? 'VC';
      // Normalize common long-form type names from legacy databases or inputs
      if (initialType == 'Venture Capital') {
        initialType = 'VC';
      } else if (initialType == 'Angel Investor') {
        initialType = 'Angel';
      } else if (initialType == 'Private Equity') {
        initialType = 'PE';
      }

      if (!_types.contains(initialType) && initialType.isNotEmpty) {
        // If it's a completely unknown type but we have it from db, we could auto-add it to types
        _types.add(initialType);
        _saveTypes(); // Save it back so it becomes an allowed type
      }
      
      _type = initialType;

      _isInit = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _websiteController.dispose();
    _contactController.dispose();
    _logoUrlController.dispose();
    _focusController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadLogo() async {
    final picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => _isSaving = true);
        final bytes = await image.readAsBytes();
        final ctrl = Provider.of<InvestorsController>(context, listen: false);
        final url = await ctrl.uploadInvestorLogo(bytes, image.name);
        setState(() => _isSaving = false);
        
        if (url != null) {
          _logoUrlController.text = url;
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Logo uploaded successfully')),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to upload logo')),
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

    final proposedChanges = <String, dynamic>{
      if (_nameController.text.trim() != _existingInvestor?.name)
        'name': _nameController.text.trim(),
      if (_type != _existingInvestor?.type) 'type': _type,
      if (_logoUrlController.text.trim() != _existingInvestor?.logoUrl)
        'logo_url': _logoUrlController.text.trim(),
      if (_websiteController.text.trim() != _existingInvestor?.websiteUrl)
        'website_url': _websiteController.text.trim(),
      if (_contactController.text.trim() != _existingInvestor?.contactInfo)
        'contact_info': _contactController.text.trim(),
      if (_focusController.text.trim() != _existingInvestor?.investmentFocus)
        'investment_focus': _focusController.text.trim(),
    };

    if (_selectedStages.join(',') !=
        (_existingInvestor?.preferredStages?.join(',') ?? '')) {
      proposedChanges['preferred_stages'] = _selectedStages;
    }

    if (_selectedIndustries.join(',') !=
        (_existingInvestor?.preferredIndustries?.join(',') ?? '')) {
      proposedChanges['preferred_industries'] = _selectedIndustries;
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
      entityType: 'Investor',
      entityId: widget.investorId,
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Investor'.tr(context)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Investor Name',
                        ),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _type,
                              decoration: const InputDecoration(labelText: 'Type'),
                              items: _types.map((String val) {
                                return DropdownMenuItem(
                                  value: val,
                                  child: Text(val),
                                );
                              }).toList(),
                              onChanged: (newVal) {
                                setState(() {
                                  _type = newVal;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: IconButton(
                              icon: const Icon(Icons.edit, color: AppColors.primary),
                              tooltip: 'Manage Types',
                              onPressed: _showManageTypesDialog,
                            ),
                          ),
                        ],
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
                                _logoUrlController.text.isNotEmpty
                                    ? 'Logo uploaded'
                                    : 'No logo selected',
                                style: TextStyle(
                                  color: _logoUrlController.text.isNotEmpty
                                      ? AppColors.success
                                      : AppColors.textSecondary,
                                  fontWeight: _logoUrlController.text.isNotEmpty ? FontWeight.bold : FontWeight.normal,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: _isSaving ? null : _pickAndUploadLogo,
                              icon: const Icon(Icons.upload_file, size: 18),
                              label: const Text('Upload'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _websiteController,
                        decoration: const InputDecoration(
                          labelText: 'Website URL (Optional)',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _contactController,
                        decoration: const InputDecoration(
                          labelText: 'Contact Email/Phone',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _focusController,
                        decoration: const InputDecoration(
                          labelText: 'Investment Focus',
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      EditableMultiSelectField(
                        label: 'Preferred Stages',
                        storageKey: 'investor_preferred_stages',
                        defaultOptions: const ['Pre-seed', 'Seed', 'Series A', 'Series B', 'Series C+'],
                        initialValues: _selectedStages,
                        onChanged: (values) {
                          setState(() {
                            _selectedStages = values;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      EditableMultiSelectField(
                        label: 'Preferred Industries',
                        storageKey: 'investor_preferred_industries',
                        defaultOptions: const ['FinTech', 'HealthTech', 'EdTech', 'E-commerce', 'SaaS', 'AI & Data'],
                        initialValues: _selectedIndustries,
                        onChanged: (values) {
                          setState(() {
                            _selectedIndustries = values;
                          });
                        },
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _isSaving ? null : _saveForm,
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text('Update Investor'.tr(context)),
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

  void _showManageTypesDialog() {
    final newTypeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Manage Investor Types', style: TextStyle(fontWeight: FontWeight.bold)),
              contentPadding: const EdgeInsets.all(24),
              content: SizedBox(
                width: 450,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: newTypeController,
                            decoration: const InputDecoration(
                              labelText: 'New Type',
                              border: OutlineInputBorder(),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            onSubmitted: (val) {
                              if (val.trim().isNotEmpty && !_types.contains(val.trim())) {
                                setState(() {
                                  _types.add(val.trim());
                                  if (_type == null) _type = val.trim();
                                  _saveTypes();
                                });
                                setDialogState(() {});
                                newTypeController.clear();
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            final val = newTypeController.text.trim();
                            if (val.isNotEmpty && !_types.contains(val)) {
                              setState(() {
                                _types.add(val);
                                if (_type == null) _type = val;
                                _saveTypes();
                              });
                              setDialogState(() {});
                              newTypeController.clear();
                            }
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (_types.isEmpty)
                      const Text(
                        'No types available.',
                        style: TextStyle(color: AppColors.textSecondary),
                      )
                    else
                      Container(
                        constraints: const BoxConstraints(maxHeight: 350),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: _types.length,
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final type = _types[index];
                            return ListTile(
                              dense: true,
                              title: Text(type, style: const TextStyle(fontWeight: FontWeight.w500)),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                                tooltip: 'Delete option',
                                onPressed: () {
                                  setState(() {
                                    _types.removeAt(index);
                                    if (_type == type) {
                                      _type = _types.isNotEmpty ? _types.first : null;
                                    }
                                    _saveTypes();
                                  });
                                  setDialogState(() {});
                                },
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
