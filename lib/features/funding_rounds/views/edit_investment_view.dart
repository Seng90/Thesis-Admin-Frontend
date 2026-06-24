import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:investrack_admin/features/funding_rounds/controllers/investments_controller.dart';
import 'package:investrack_admin/features/funding_rounds/models/investment_model.dart';
import 'package:investrack_admin/features/revisions/controllers/revisions_controller.dart';
import 'package:investrack_admin/features/companies/controllers/companies_controller.dart';
import 'package:investrack_admin/features/investors/controllers/investors_controller.dart';
import 'package:investrack_admin/utils/constants.dart';
import 'package:investrack_admin/services/api_service.dart';

class EditInvestmentView extends StatefulWidget {
  final String investmentId;
  const EditInvestmentView({super.key, required this.investmentId});

  @override
  State<EditInvestmentView> createState() => _EditInvestmentViewState();
}

class _EditInvestmentViewState extends State<EditInvestmentView> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _currencyController = TextEditingController();
  final _referenceUrlController = TextEditingController();
  final _customInvestorNameController = TextEditingController();
  DateTime? _investDate;

  String? _selectedCompanyId;
  String? _selectedInvestorId;
  String? _selectedRoundId;
  String _selectedStatus = 'Pending';
  bool _isOtherInvestor = false;

  Investment? _existingInvestment;
  bool _isSaving = false;
  bool _isLoadingData = true;

  // Funding rounds loaded from API
  List<Map<String, dynamic>> _fundingRounds = [];
  bool _isLoadingRounds = false;

  static const List<String> _statusOptions = ['Pending', 'Completed', 'Refunded'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDependencies();
      _loadInvestment();
    });
  }

  Future<void> _loadDependencies() async {
    final companiesCtrl = Provider.of<CompaniesController>(context, listen: false);
    final investorsCtrl = Provider.of<InvestorsController>(context, listen: false);

    if (companiesCtrl.companies.isEmpty) {
      companiesCtrl.loadCompanies();
    }
    if (investorsCtrl.investors.isEmpty) {
      investorsCtrl.loadInvestors();
    }

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
      // Silently fail
    } finally {
      setState(() => _isLoadingRounds = false);
    }
  }

  Future<void> _loadInvestment() async {
    try {
      final api = ApiService();
      final response = await api.client.get('/admin/investments/${widget.investmentId}');
      final found = Investment.fromJson(response.data);
      setState(() {
        _existingInvestment = found;
        _amountController.text = found.amount.toString();
        _currencyController.text = found.currency;
        _referenceUrlController.text = found.referenceUrl ?? '';
        _selectedCompanyId = found.companyId;
        _selectedInvestorId = found.investorId;
        _selectedRoundId = found.roundId;
        _selectedStatus = found.status;
        _investDate = found.investDate;
        _isOtherInvestor = found.investorId == null;
        _customInvestorNameController.text = found.customInvestorName ?? '';
        _isLoadingData = false;
      });
    } catch (e) {
      if (!mounted) return;
      // Fallback: try from controller
      final controller = Provider.of<InvestmentsController>(context, listen: false);
      if (controller.investments.isEmpty) {
        await controller.fetchInvestments();
      }
      try {
        final found = controller.investments.firstWhere((i) => i.id == widget.investmentId);
        setState(() {
          _existingInvestment = found;
          _amountController.text = found.amount.toString();
          _currencyController.text = found.currency;
          _referenceUrlController.text = found.referenceUrl ?? '';
          _selectedCompanyId = found.companyId;
          _selectedInvestorId = found.investorId;
          _selectedRoundId = found.roundId;
          _selectedStatus = found.status;
          _investDate = found.investDate;
          _isOtherInvestor = found.investorId == null;
          _customInvestorNameController.text = found.customInvestorName ?? '';
          _isLoadingData = false;
        });
      } catch (_) {
        setState(() => _isLoadingData = false);
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _currencyController.dispose();
    _referenceUrlController.dispose();
    _customInvestorNameController.dispose();
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

    Map<String, dynamic> proposedChanges = {};
    if (double.tryParse(_amountController.text.trim()) != _existingInvestment?.amount) {
      proposedChanges['amount'] = double.tryParse(_amountController.text.trim()) ?? 0.0;
    }
    if (_currencyController.text.trim() != _existingInvestment?.currency) {
      proposedChanges['currency'] = _currencyController.text.trim();
    }
    if (_referenceUrlController.text.trim() != (_existingInvestment?.referenceUrl ?? '')) {
      proposedChanges['reference_url'] = _referenceUrlController.text.trim();
    }
    if (_selectedCompanyId != _existingInvestment?.companyId) {
      proposedChanges['company_id'] = _selectedCompanyId;
    }
    if (_selectedRoundId != _existingInvestment?.roundId) {
      proposedChanges['round_id'] = _selectedRoundId;
    }
    if (_selectedStatus != _existingInvestment?.status) {
      proposedChanges['status'] = _selectedStatus;
    }
    if (_investDate != _existingInvestment?.investDate) {
      proposedChanges['invest_date'] = _investDate!.toIso8601String();
    }

    // Handle investor changes
    if (_isOtherInvestor) {
      if (_existingInvestment?.investorId != null) {
        proposedChanges['investor_id'] = null;
      }
      final customName = _customInvestorNameController.text.trim().isNotEmpty
          ? _customInvestorNameController.text.trim()
          : 'Others';
      if (customName != _existingInvestment?.customInvestorName) {
        proposedChanges['custom_investor_name'] = customName;
      }
    } else {
      if (_selectedInvestorId != _existingInvestment?.investorId) {
        proposedChanges['investor_id'] = _selectedInvestorId;
      }
      if (_existingInvestment?.customInvestorName != null) {
        proposedChanges['custom_investor_name'] = null;
      }
    }

    if (proposedChanges.isEmpty) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No changes made.')));
      context.pop();
      return;
    }

    final success = await revisionsController.createRevision(
      entityType: 'Investment',
      entityId: widget.investmentId,
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
          const SnackBar(content: Text('Edit submitted for review!'), backgroundColor: AppColors.success),
        );
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Investment')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_existingInvestment == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Investment')),
        body: const Center(child: Text('Investment not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Investment'),
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
                        'Investment Information',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 16),

                      // Company Dropdown
                      Consumer<CompaniesController>(
                        builder: (context, ctrl, _) {
                          final companyIds = ctrl.companies.map((c) => c.id).toSet();
                          final currentVal = companyIds.contains(_selectedCompanyId) ? _selectedCompanyId : null;

                          return DropdownButtonFormField<String>(
                            initialValue: currentVal,
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

                      // Investor Toggle
                      SwitchListTile(
                        title: const Text('Other / Anonymous Investor'),
                        subtitle: const Text('Use this for unnamed groups or minor investors'),
                        value: _isOtherInvestor,
                        activeThumbColor: AppColors.primary,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (v) {
                          setState(() {
                            _isOtherInvestor = v;
                            if (v) _selectedInvestorId = null;
                          });
                        },
                      ),
                      const SizedBox(height: 8),

                      // Investor Dropdown OR Custom Name
                      if (_isOtherInvestor)
                        TextFormField(
                          controller: _customInvestorNameController,
                          decoration: const InputDecoration(
                            labelText: 'Group / Custom Name',
                            hintText: 'e.g. Friends & Family, Angel Syndicate',
                            prefixIcon: Icon(Icons.groups),
                          ),
                        )
                      else
                        Consumer<InvestorsController>(
                          builder: (context, ctrl, _) {
                            final investorIds = ctrl.investors.map((i) => i.id).toSet();
                            final currentVal = investorIds.contains(_selectedInvestorId) ? _selectedInvestorId : null;

                            return DropdownButtonFormField<String>(
                              initialValue: currentVal,
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
                          : Builder(builder: (context) {
                              final roundIds = _fundingRounds.map((r) => r['id']?.toString() ?? '').toSet();
                              final currentVal = roundIds.contains(_selectedRoundId) ? _selectedRoundId : null;

                              return DropdownButtonFormField<String>(
                                initialValue: currentVal,
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
                              );
                            }),

                      const SizedBox(height: 32),
                      const Text(
                        'Financial Details',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
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

                      // Status Dropdown
                      DropdownButtonFormField<String>(
                        initialValue: _statusOptions.contains(_selectedStatus) ? _selectedStatus : 'Pending',
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          prefixIcon: Icon(Icons.flag_outlined),
                        ),
                        items: _statusOptions.map((s) {
                          return DropdownMenuItem(value: s, child: Text(s));
                        }).toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _selectedStatus = v);
                        },
                        isExpanded: true,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _referenceUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Reference URL (Optional)',
                          prefixIcon: Icon(Icons.link),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Date Picker
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
                        child: ElevatedButton.icon(
                          onPressed: _isSaving ? null : _saveForm,
                          icon: _isSaving
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.save),
                          label: Text(_isSaving ? 'Updating...' : 'Update Investment'),
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
