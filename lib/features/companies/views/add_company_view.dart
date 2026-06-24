import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:investrack_admin/features/revisions/controllers/revisions_controller.dart';
import 'package:investrack_admin/utils/constants.dart';

class AddCompanyView extends StatefulWidget {
  const AddCompanyView({super.key});

  @override
  State<AddCompanyView> createState() => _AddCompanyViewState();
}

class _AddCompanyViewState extends State<AddCompanyView> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _industryController = TextEditingController();
  final _locationController = TextEditingController();
  final _emailController = TextEditingController();
  final _logoUrlController = TextEditingController();
  final _websiteUrlController = TextEditingController();

  // New fields
  final _regNumberController = TextEditingController();
  final _taxIdController = TextEditingController();
  final _facebookUrlController = TextEditingController();
  final _linkedinUrlController = TextEditingController();
  final _headquartersController = TextEditingController();
  final _branchCountController = TextEditingController();
  final _keyProductsInputController = TextEditingController();
  final _keyPartnersInputController = TextEditingController();

  String _status = 'Pending';
  String _operatingStatus = 'Active';
  String? _employeeCount;
  DateTime? _foundedDate;
  bool _isSaving = false;
  final List<String> _keyProducts = [];
  final List<String> _keyPartners = [];

  static const List<String> _employeeCountOptions = ['1-10', '11-50', '51-200', '200+'];
  static const List<String> _operatingStatusOptions = ['Active', 'Acquired', 'Closed'];

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _industryController.dispose();
    _locationController.dispose();
    _emailController.dispose();
    _logoUrlController.dispose();
    _websiteUrlController.dispose();
    _regNumberController.dispose();
    _taxIdController.dispose();
    _facebookUrlController.dispose();
    _linkedinUrlController.dispose();
    _headquartersController.dispose();
    _branchCountController.dispose();
    _keyProductsInputController.dispose();
    _keyPartnersInputController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _foundedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _foundedDate = picked;
      });
    }
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    
    final revisionsController = Provider.of<RevisionsController>(context, listen: false);
    
    Map<String, dynamic> proposedChanges = {
      'name': _nameController.text.trim(),
      'description': _descController.text.trim(),
      'industry': _industryController.text.trim(),
      'location': _locationController.text.trim(),
      'contact_email': _emailController.text.trim(),
      'status': _status,
      'operating_status': _operatingStatus,
    };
    
    if (_logoUrlController.text.trim().isNotEmpty) {
      proposedChanges['logo_url'] = _logoUrlController.text.trim();
    }
    if (_websiteUrlController.text.trim().isNotEmpty) {
      proposedChanges['website_url'] = _websiteUrlController.text.trim();
    }
    if (_foundedDate != null) {
      proposedChanges['founded_date'] = _foundedDate!.toIso8601String();
    }
    // New fields
    if (_regNumberController.text.trim().isNotEmpty) {
      proposedChanges['registration_number'] = _regNumberController.text.trim();
    }
    if (_taxIdController.text.trim().isNotEmpty) {
      proposedChanges['tax_id'] = _taxIdController.text.trim();
    }
    if (_facebookUrlController.text.trim().isNotEmpty) {
      proposedChanges['facebook_url'] = _facebookUrlController.text.trim();
    }
    if (_linkedinUrlController.text.trim().isNotEmpty) {
      proposedChanges['linkedin_url'] = _linkedinUrlController.text.trim();
    }
    if (_headquartersController.text.trim().isNotEmpty) {
      proposedChanges['headquarters_address'] = _headquartersController.text.trim();
    }
    if (_branchCountController.text.trim().isNotEmpty) {
      proposedChanges['branch_count'] = int.tryParse(_branchCountController.text.trim()) ?? 0;
    }
    if (_employeeCount != null) {
      proposedChanges['employee_count'] = _employeeCount;
    }
    if (_keyProducts.isNotEmpty) {
      proposedChanges['key_products'] = _keyProducts;
    }
    if (_keyPartners.isNotEmpty) {
      proposedChanges['key_partners'] = _keyPartners;
    }

    final success = await revisionsController.createRevision(
      entityType: 'Company',
      entityId: null,
      proposedChanges: proposedChanges,
    );
    
    if (mounted) {
      setState(() => _isSaving = false);
      
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(revisionsController.errorMessage ?? 'Failed to submit revision'), backgroundColor: AppColors.error),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Company creation submitted for review!'), backgroundColor: AppColors.success),
        );
        context.pop();
      }
    }
  }

  Widget _buildTagInput({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    required List<String> tags,
    required VoidCallback onAdd,
    required void Function(int) onRemove,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            prefixIcon: Icon(icon),
            suffixIcon: IconButton(
              icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
              onPressed: onAdd,
              tooltip: 'Add tag',
            ),
          ),
          onSubmitted: (_) => onAdd(),
        ),
        if (tags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: tags.asMap().entries.map((entry) {
              return Chip(
                label: Text(entry.value, style: const TextStyle(fontSize: 12)),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () => onRemove(entry.key),
                backgroundColor: AppColors.primaryLight,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Company'),
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
                      // ── Section 1: Basic Info ──
                      const Text(
                        'Company Information',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Company Name *',
                          hintText: 'e.g. Lao Digital Solutions',
                          prefixIcon: Icon(Icons.business),
                        ),
                        validator: (v) => v!.trim().isEmpty ? 'Company name is required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Description *',
                          hintText: 'Brief description of the company...',
                          prefixIcon: Icon(Icons.description),
                          alignLabelWithHint: true,
                        ),
                        validator: (v) => v!.trim().isEmpty ? 'Description is required' : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _industryController,
                              decoration: const InputDecoration(
                                labelText: 'Industry *',
                                hintText: 'e.g. FinTech',
                                prefixIcon: Icon(Icons.category),
                              ),
                              validator: (v) => v!.trim().isEmpty ? 'Industry is required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _locationController,
                              decoration: const InputDecoration(
                                labelText: 'Location *',
                                hintText: 'e.g. Vientiane',
                                prefixIcon: Icon(Icons.location_on),
                              ),
                              validator: (v) => v!.trim().isEmpty ? 'Location is required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Contact Email *',
                          hintText: 'info@company.com',
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => v!.trim().isEmpty || !v.contains('@') ? 'Enter a valid email' : null,
                      ),

                      // ── Section 2: Legal & Tax ──
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.0),
                        child: Divider(),
                      ),
                      const Text(
                        'Legal & Tax Information',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _regNumberController,
                              decoration: InputDecoration(
                                labelText: 'Registration Number',
                                hintText: 'e.g. REG-001234',
                                prefixIcon: const Icon(Icons.assignment),
                                suffixIcon: PopupMenuButton<String>(
                                  icon: const Icon(Icons.arrow_drop_down),
                                  tooltip: 'Select predefined value',
                                  onSelected: (val) {
                                    _regNumberController.text = val;
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'Not Available',
                                      child: Text('Not Available'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _taxIdController,
                              decoration: InputDecoration(
                                labelText: 'Tax ID',
                                hintText: 'e.g. TAX-56789',
                                prefixIcon: const Icon(Icons.receipt_long),
                                suffixIcon: PopupMenuButton<String>(
                                  icon: const Icon(Icons.arrow_drop_down),
                                  tooltip: 'Select predefined value',
                                  onSelected: (val) {
                                    _taxIdController.text = val;
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'Not Available',
                                      child: Text('Not Available'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // ── Section 3: Organization Size ──
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.0),
                        child: Divider(),
                      ),
                      const Text(
                        'Organization Details',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _employeeCount,
                              decoration: const InputDecoration(
                                labelText: 'Employee Count',
                                prefixIcon: Icon(Icons.people),
                              ),
                              items: _employeeCountOptions.map((s) {
                                return DropdownMenuItem(value: s, child: Text(s));
                              }).toList(),
                              onChanged: (v) => setState(() => _employeeCount = v),
                              isExpanded: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _branchCountController,
                              decoration: const InputDecoration(
                                labelText: 'Branch Count',
                                hintText: 'e.g. 3',
                                prefixIcon: Icon(Icons.store),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _headquartersController,
                        decoration: const InputDecoration(
                          labelText: 'Headquarters Address',
                          hintText: 'e.g. 123 Samsenthai Road, Vientiane',
                          prefixIcon: Icon(Icons.location_city),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _operatingStatus,
                        decoration: const InputDecoration(
                          labelText: 'Operating Status',
                          prefixIcon: Icon(Icons.power_settings_new),
                        ),
                        items: _operatingStatusOptions.map((s) {
                          return DropdownMenuItem(value: s, child: Text(s));
                        }).toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _operatingStatus = v);
                        },
                        isExpanded: true,
                      ),

                      // ── Section 4: Social Media ──
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.0),
                        child: Divider(),
                      ),
                      const Text(
                        'Web & Social Media',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _websiteUrlController,
                              decoration: const InputDecoration(
                                labelText: 'Website URL',
                                hintText: 'https://company.com',
                                prefixIcon: Icon(Icons.language),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _logoUrlController,
                              decoration: const InputDecoration(
                                labelText: 'Logo URL',
                                hintText: 'https://..../logo.png',
                                prefixIcon: Icon(Icons.image),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _facebookUrlController,
                              decoration: const InputDecoration(
                                labelText: 'Facebook URL',
                                hintText: 'https://facebook.com/...',
                                prefixIcon: Icon(Icons.facebook),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _linkedinUrlController,
                              decoration: const InputDecoration(
                                labelText: 'LinkedIn URL',
                                hintText: 'https://linkedin.com/...',
                                prefixIcon: Icon(Icons.work),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // ── Section 5: Business Highlights ──
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.0),
                        child: Divider(),
                      ),
                      const Text(
                        'Business Highlights',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 16),
                      _buildTagInput(
                        label: 'Key Products',
                        hint: 'Type product name & press Enter...',
                        icon: Icons.inventory_2,
                        controller: _keyProductsInputController,
                        tags: _keyProducts,
                        onAdd: () {
                          final text = _keyProductsInputController.text.trim();
                          if (text.isNotEmpty && !_keyProducts.contains(text)) {
                            setState(() {
                              _keyProducts.add(text);
                              _keyProductsInputController.clear();
                            });
                          }
                        },
                        onRemove: (i) => setState(() => _keyProducts.removeAt(i)),
                      ),
                      const SizedBox(height: 16),
                      _buildTagInput(
                        label: 'Key Partners',
                        hint: 'Type partner name & press Enter...',
                        icon: Icons.handshake,
                        controller: _keyPartnersInputController,
                        tags: _keyPartners,
                        onAdd: () {
                          final text = _keyPartnersInputController.text.trim();
                          if (text.isNotEmpty && !_keyPartners.contains(text)) {
                            setState(() {
                              _keyPartners.add(text);
                              _keyPartnersInputController.clear();
                            });
                          }
                        },
                        onRemove: (i) => setState(() => _keyPartners.removeAt(i)),
                      ),

                      // ── Section 6: Status & Date ──
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.0),
                        child: Divider(),
                      ),
                      const Text(
                        'Status & Date',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: _pickDate,
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Founded Date',
                                  prefixIcon: Icon(Icons.calendar_today),
                                ),
                                child: Text(
                                  _foundedDate != null
                                      ? '${_foundedDate!.year}-${_foundedDate!.month.toString().padLeft(2, '0')}-${_foundedDate!.day.toString().padLeft(2, '0')}'
                                      : 'Select a date...',
                                  style: TextStyle(
                                    color: _foundedDate != null ? AppColors.textPrimary : AppColors.textMuted,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _status,
                              decoration: const InputDecoration(
                                labelText: 'Status',
                                prefixIcon: Icon(Icons.flag),
                              ),
                              items: ['Pending', 'Approved', 'Rejected'].map((String val) {
                                return DropdownMenuItem(
                                  value: val,
                                  child: Text(val),
                                );
                              }).toList(),
                              onChanged: (newVal) {
                                setState(() {
                                  _status = newVal!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _isSaving ? null : _saveForm,
                          icon: _isSaving 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.save),
                          label: Text(_isSaving ? 'Saving...' : 'Save Company'),
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
