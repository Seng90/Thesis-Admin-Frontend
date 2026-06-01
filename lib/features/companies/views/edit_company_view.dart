import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:investrack_admin/features/companies/controllers/companies_controller.dart';
import 'package:investrack_admin/features/companies/models/company_model.dart';
import 'package:investrack_admin/utils/constants.dart';

class EditCompanyView extends StatefulWidget {
  final String companyId;

  const EditCompanyView({super.key, required this.companyId});

  @override
  State<EditCompanyView> createState() => _EditCompanyViewState();
}

class _EditCompanyViewState extends State<EditCompanyView> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _industryController;
  late TextEditingController _locationController;
  late TextEditingController _emailController;
  late TextEditingController _logoUrlController;
  late TextEditingController _websiteUrlController;
  late String _status;
  DateTime? _foundedDate;
  bool _isSaving = false;
  bool _isInit = false;
  Company? _existingCompany;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final controller = Provider.of<CompaniesController>(context, listen: false);
      try {
        _existingCompany = controller.companies.firstWhere((c) => c.id == widget.companyId);
      } catch (_) {
        _existingCompany = null;
      }
      
      _nameController = TextEditingController(text: _existingCompany?.name ?? '');
      _descController = TextEditingController(text: _existingCompany?.description ?? '');
      _industryController = TextEditingController(text: _existingCompany?.industry ?? '');
      _locationController = TextEditingController(text: _existingCompany?.location ?? '');
      _emailController = TextEditingController(text: _existingCompany?.contactEmail ?? '');
      _logoUrlController = TextEditingController(text: _existingCompany?.logoUrl ?? '');
      _websiteUrlController = TextEditingController(text: _existingCompany?.websiteUrl ?? '');
      _status = _existingCompany?.status ?? 'Pending';
      _foundedDate = _existingCompany?.foundedDate;
      
      _isInit = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _industryController.dispose();
    _locationController.dispose();
    _emailController.dispose();
    _logoUrlController.dispose();
    _websiteUrlController.dispose();
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
    
    final controller = Provider.of<CompaniesController>(context, listen: false);
    
    final company = Company(
      id: widget.companyId,
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      industry: _industryController.text.trim(),
      location: _locationController.text.trim(),
      contactEmail: _emailController.text.trim(),
      status: _status,
      viewCount: _existingCompany?.viewCount ?? 0,
      foundedDate: _foundedDate,
      logoUrl: _logoUrlController.text.trim().isNotEmpty ? _logoUrlController.text.trim() : null,
      websiteUrl: _websiteUrlController.text.trim().isNotEmpty ? _websiteUrlController.text.trim() : null,
      approvedBy: _existingCompany?.approvedBy,
    );

    await controller.updateCompany(company);
    
    if (mounted) {
      setState(() => _isSaving = false);
      
      if (controller.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(controller.errorMessage!), backgroundColor: AppColors.error),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Company updated successfully!'), backgroundColor: AppColors.success),
        );
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_existingCompany == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Company')),
        body: const Center(child: Text('Company not found.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Company'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Company Information',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Company Name *',
                          prefixIcon: Icon(Icons.business),
                        ),
                        validator: (v) => v!.trim().isEmpty ? 'Company name is required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Description *',
                          prefixIcon: Icon(Icons.description),
                          alignLabelWithHint: true,
                        ),
                        validator: (v) => v!.trim().isEmpty ? 'Description is required' : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _industryController,
                              decoration: const InputDecoration(
                                labelText: 'Industry *',
                                prefixIcon: Icon(Icons.category),
                              ),
                              validator: (v) => v!.trim().isEmpty ? 'Industry is required' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _locationController,
                              decoration: const InputDecoration(
                                labelText: 'Location *',
                                prefixIcon: Icon(Icons.location_on),
                              ),
                              validator: (v) => v!.trim().isEmpty ? 'Location is required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Contact Email *',
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => v!.trim().isEmpty || !v.contains('@') ? 'Enter a valid email' : null,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Additional Details',
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
                                prefixIcon: Icon(Icons.language),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _logoUrlController,
                              decoration: const InputDecoration(
                                labelText: 'Logo URL',
                                prefixIcon: Icon(Icons.image),
                              ),
                            ),
                          ),
                        ],
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
                          label: Text(_isSaving ? 'Updating...' : 'Update Company'),
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
