import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:investrack_admin/features/revisions/controllers/revisions_controller.dart';
import 'package:investrack_admin/features/companies/controllers/companies_controller.dart';
import 'package:investrack_admin/features/investors/controllers/investors_controller.dart';
import 'package:investrack_admin/utils/constants.dart';
import 'package:investrack_admin/services/api_service.dart';

class AddInvestmentView extends StatefulWidget {
  const AddInvestmentView({super.key});

  @override
  State<AddInvestmentView> createState() => _AddInvestmentViewState();
}

class _AddInvestmentViewState extends State<AddInvestmentView> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _currencyController = TextEditingController(text: 'USD');
  DateTime? _investDate;
  bool _isSaving = false;

  String? _selectedCompanyId;
  String? _selectedInvestorId;
  String? _selectedRoundId;

  // Funding rounds loaded from API
  List<Map<String, dynamic>> _fundingRounds = [];
  bool _isLoadingRounds = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDependencies();
    });
  }

  Future<void> _loadDependencies() async {
    // Load companies and investors if not already loaded
    final companiesCtrl = Provider.of<CompaniesController>(context, listen: false);
    final investorsCtrl = Provider.of<InvestorsController>(context, listen: false);

    if (companiesCtrl.companies.isEmpty) {
      companiesCtrl.loadCompanies();
    }
    if (investorsCtrl.investors.isEmpty) {
      investorsCtrl.loadInvestors();
    }

    // Load funding rounds
    await _loadFundingRounds();
  }

  Future<void> _loadFundingRounds() async {
    setState(() => _isLoadingRounds = true);
    try {
      final api = ApiService();
      final response = await api.client.get('/admin/funding-rounds');
      final List<dynamic> data = response.data is List ? response.data : [];
      setState(() {
        _fundingRounds = data.map((e) => Map<String, dynamic>.from(e)).toList();
      });
    } catch (e) {
      // Silently fail — user can still type round ID if needed
    } finally {
      setState(() => _isLoadingRounds = false);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _currencyController.dispose();
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
    if (_selectedCompanyId == null || _selectedInvestorId == null || _selectedRoundId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select Company, Investor, and Funding Round')));
      return;
    }

    setState(() => _isSaving = true);
    final revisionsController = Provider.of<RevisionsController>(context, listen: false);

    Map<String, dynamic> proposedChanges = {
      'amount': double.tryParse(_amountController.text.trim()) ?? 0.0,
      'currency': _currencyController.text.trim(),
      'company_id': _selectedCompanyId,
      'investor_id': _selectedInvestorId,
      'round_id': _selectedRoundId,
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
                      // Company Dropdown
                      Consumer<CompaniesController>(
                        builder: (context, ctrl, _) {
                          return DropdownButtonFormField<String>(
                            initialValue: _selectedCompanyId,
                            decoration: const InputDecoration(
                              labelText: 'Company *',
                              prefixIcon: Icon(Icons.business),
                            ),
                            items: ctrl.companies.map((c) {
                              return DropdownMenuItem(
                                value: c.id,
                                child: Text(c.name, overflow: TextOverflow.ellipsis),
                              );
                            }).toList(),
                            onChanged: (v) => setState(() => _selectedCompanyId = v),
                            validator: (v) => v == null ? 'Please select a company' : null,
                            isExpanded: true,
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      // Investor Dropdown
                      Consumer<InvestorsController>(
                        builder: (context, ctrl, _) {
                          return DropdownButtonFormField<String>(
                            initialValue: _selectedInvestorId,
                            decoration: const InputDecoration(
                              labelText: 'Investor *',
                              prefixIcon: Icon(Icons.person),
                            ),
                            items: ctrl.investors.map((i) {
                              return DropdownMenuItem(
                                value: i.id,
                                child: Text(i.name, overflow: TextOverflow.ellipsis),
                              );
                            }).toList(),
                            onChanged: (v) => setState(() => _selectedInvestorId = v),
                            validator: (v) => v == null ? 'Please select an investor' : null,
                            isExpanded: true,
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      // Funding Round Dropdown
                      _isLoadingRounds
                          ? const LinearProgressIndicator()
                          : DropdownButtonFormField<String>(
                              initialValue: _selectedRoundId,
                              decoration: const InputDecoration(
                                labelText: 'Funding Round *',
                                prefixIcon: Icon(Icons.cyclone),
                              ),
                              items: _fundingRounds.map((r) {
                                final id = r['id']?.toString() ?? '';
                                final name = r['round_name'] ?? r['name'] ?? 'Round ${id.substring(0, id.length > 8 ? 8 : id.length)}';
                                return DropdownMenuItem(
                                  value: id,
                                  child: Text(name.toString(), overflow: TextOverflow.ellipsis),
                                );
                              }).toList(),
                              onChanged: (v) => setState(() => _selectedRoundId = v),
                              validator: (v) => v == null ? 'Please select a funding round' : null,
                              isExpanded: true,
                            ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _amountController,
                              decoration: const InputDecoration(
                                labelText: 'Amount *',
                                prefixIcon: Icon(Icons.attach_money),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 120,
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
