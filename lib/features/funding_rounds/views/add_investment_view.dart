import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:investrack_admin/features/revisions/controllers/revisions_controller.dart';
import 'package:investrack_admin/utils/constants.dart';

class AddInvestmentView extends StatefulWidget {
  const AddInvestmentView({super.key});

  @override
  State<AddInvestmentView> createState() => _AddInvestmentViewState();
}

class _AddInvestmentViewState extends State<AddInvestmentView> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _currencyController = TextEditingController(text: 'USD');
  final _companyIdController = TextEditingController();
  final _investorIdController = TextEditingController();
  final _roundIdController = TextEditingController();
  DateTime? _investDate;
  bool _isSaving = false;

  @override
  void dispose() {
    _amountController.dispose();
    _currencyController.dispose();
    _companyIdController.dispose();
    _investorIdController.dispose();
    _roundIdController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _investDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _investDate = picked;
      });
    }
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_investDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select an investment date')));
      return;
    }
    
    setState(() => _isSaving = true);
    final revisionsController = Provider.of<RevisionsController>(context, listen: false);
    
    Map<String, dynamic> proposedChanges = {
      'amount': double.tryParse(_amountController.text.trim()) ?? 0.0,
      'currency': _currencyController.text.trim(),
      'company_id': _companyIdController.text.trim(),
      'investor_id': _investorIdController.text.trim(),
      'round_id': _roundIdController.text.trim(),
      'invest_date': _investDate!.toIso8601String(),
    };

    final success = await revisionsController.createRevision(
      entityType: 'Investment',
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
          const SnackBar(content: Text('Investment creation submitted for review!'), backgroundColor: AppColors.success),
        );
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Investment'),
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
                        controller: _companyIdController,
                        decoration: const InputDecoration(labelText: 'Company ID *'),
                        validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _investorIdController,
                        decoration: const InputDecoration(labelText: 'Investor ID *'),
                        validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _roundIdController,
                        decoration: const InputDecoration(labelText: 'Round ID *'),
                        validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _amountController,
                              decoration: const InputDecoration(labelText: 'Amount *'),
                              keyboardType: TextInputType.number,
                              validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _currencyController,
                              decoration: const InputDecoration(labelText: 'Currency *'),
                              validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: _pickDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Investment Date *',
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            _investDate != null
                                ? '${_investDate!.year}-${_investDate!.month.toString().padLeft(2, '0')}-${_investDate!.day.toString().padLeft(2, '0')}'
                                : 'Select a date...',
                            style: TextStyle(
                              color: _investDate != null ? AppColors.textPrimary : AppColors.textMuted,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveForm,
                          child: _isSaving 
                              ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Text('Save Investment'),
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
