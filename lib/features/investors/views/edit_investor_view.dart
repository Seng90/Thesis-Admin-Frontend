import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:investrack_admin/features/investors/controllers/investors_controller.dart';
import 'package:investrack_admin/features/investors/models/investor_model.dart';
import 'package:investrack_admin/features/revisions/controllers/revisions_controller.dart';
import 'package:investrack_admin/utils/constants.dart';
import 'package:investrack_admin/utils/localizations.dart';

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
  late String _type;
  
  bool _isSaving = false;
  bool _isInit = false;
  Investor? _existingInvestor;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final controller = Provider.of<InvestorsController>(context, listen: false);
      try {
        _existingInvestor = controller.investors.firstWhere((i) => i.id == widget.investorId);
      } catch (_) {
        _existingInvestor = null;
      }
      
      _nameController = TextEditingController(text: _existingInvestor?.name ?? '');
      _websiteController = TextEditingController(text: _existingInvestor?.websiteUrl ?? '');
      _contactController = TextEditingController(text: _existingInvestor?.contactInfo ?? '');
      _logoUrlController = TextEditingController(text: _existingInvestor?.logoUrl ?? '');
      _type = _existingInvestor?.type ?? 'Venture Capital';
      
      _isInit = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _websiteController.dispose();
    _contactController.dispose();
    _logoUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    
    final revController = Provider.of<RevisionsController>(context, listen: false);
    
    final proposedChanges = {
      if (_nameController.text.trim() != _existingInvestor?.name) 'name': _nameController.text.trim(),
      if (_type != _existingInvestor?.type) 'type': _type,
      if (_logoUrlController.text.trim() != _existingInvestor?.logoUrl) 'logo_url': _logoUrlController.text.trim(),
      if (_websiteController.text.trim() != _existingInvestor?.websiteUrl) 'website_url': _websiteController.text.trim(),
      if (_contactController.text.trim() != _existingInvestor?.contactInfo) 'contact_info': _contactController.text.trim(),
    };

    if (proposedChanges.isEmpty) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No changes made.')));
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
          SnackBar(content: Text(revController.errorMessage ?? 'Failed to submit revision'), backgroundColor: AppColors.error),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Edit submitted for review!'), backgroundColor: AppColors.success),
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
                        decoration: const InputDecoration(labelText: 'Investor Name'),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _type,
                        decoration: const InputDecoration(labelText: 'Type'),
                        items: ['Venture Capital', 'Angel Investor', 'Private Equity'].map((String val) {
                          return DropdownMenuItem(
                            value: val,
                            child: Text(val),
                          );
                        }).toList(),
                        onChanged: (newVal) {
                          if (newVal != null) {
                            setState(() {
                              _type = newVal;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _logoUrlController,
                        decoration: const InputDecoration(labelText: 'Logo URL'),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _websiteController,
                        decoration: const InputDecoration(labelText: 'Website URL (Optional)'),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _contactController,
                        decoration: const InputDecoration(labelText: 'Contact Email/Phone'),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _isSaving ? null : _saveForm,
                        child: _isSaving 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
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
}
