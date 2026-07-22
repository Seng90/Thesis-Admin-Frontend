import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:investrack_admin/features/funding_rounds/controllers/investments_controller.dart';
import 'package:investrack_admin/features/funding_rounds/models/investment_model.dart';
import 'package:investrack_admin/features/revisions/controllers/revisions_controller.dart';
import 'package:investrack_admin/features/companies/controllers/companies_controller.dart';
import 'package:investrack_admin/features/investors/controllers/investors_controller.dart';
import 'package:investrack_admin/utils/constants.dart';

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

  static const List<String> _statusOptions = [
    'Pending',
    'Completed',
    'Refunded',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDependencies();
      _loadInvestment();
    });
  }

  Future<void> _loadDependencies() async {
    final companiesCtrl = Provider.of<CompaniesController>(
      context,
      listen: false,
    );
    final investorsCtrl = Provider.of<InvestorsController>(
      context,
      listen: false,
    );

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
      final controller = Provider.of<InvestmentsController>(context, listen: false);
      await controller.fetchFundingRounds();
      setState(() {
        _fundingRounds = controller.fundingRounds;
      });
    } catch (_) {
      // Silently fail
    } finally {
      setState(() => _isLoadingRounds = false);
    }
  }

  Future<void> _loadInvestment() async {
    try {
      final controller = Provider.of<InvestmentsController>(
        context,
        listen: false,
      );
      final found = await controller.fetchInvestmentDetail(widget.investmentId);
      if (found != null) {
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
      } else {
        throw Exception("Not found");
      }
    } catch (_) {
      if (!mounted) return;
      // Fallback: try from controller list
      final controller = Provider.of<InvestmentsController>(
        context,
        listen: false,
      );
      if (controller.investments.isEmpty) {
        await controller.fetchInvestments();
      }
      try {
        final found = controller.investments.firstWhere(
          (i) => i.id == widget.investmentId,
        );
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an investment date')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final revisionsController = Provider.of<RevisionsController>(
      context,
      listen: false,
    );

    Map<String, dynamic> proposedChanges = {};
    if (double.tryParse(_amountController.text.trim()) !=
        _existingInvestment?.amount) {
      proposedChanges['amount'] =
          double.tryParse(_amountController.text.trim()) ?? 0.0;
    }
    if (_currencyController.text.trim() != _existingInvestment?.currency) {
      proposedChanges['currency'] = _currencyController.text.trim();
    }
    if (_referenceUrlController.text.trim() !=
        (_existingInvestment?.referenceUrl ?? '')) {
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No changes made.')));
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
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Company Dropdown
                      Consumer<CompaniesController>(
                        builder: (context, ctrl, _) {
                          final companyIds = ctrl.companies
                              .map((c) => c.id)
                              .toSet();
                          final currentVal =
                              companyIds.contains(_selectedCompanyId)
                              ? _selectedCompanyId
                              : null;
                          final selectedCompany = currentVal != null ? ctrl.companies.firstWhere((c) => c.id == currentVal) : null;

                          return FormField<String>(
                            initialValue: currentVal,
                            validator: (v) => _selectedCompanyId == null ? 'Please select a company' : null,
                            builder: (formFieldState) {
                              return InkWell(
                                onTap: () {
                                  final options = ctrl.companies.map((c) => {'value': c.id, 'label': c.name}).toList();
                                  _showSearchableDialog(
                                    title: 'Select Company',
                                    options: options,
                                    currentValue: currentVal,
                                    onSelected: (val) {
                                      setState(() => _selectedCompanyId = val);
                                      formFieldState.didChange(val);
                                    },
                                  );
                                },
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'Company *',
                                    prefixIcon: const Icon(Icons.business),
                                    errorText: formFieldState.errorText,
                                  ),
                                  child: Text(
                                    selectedCompany?.name ?? 'Select Company...',
                                    style: TextStyle(color: selectedCompany != null ? AppColors.textPrimary : AppColors.textSecondary),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Investor Toggle
                      SwitchListTile(
                        title: const Text('Other / Anonymous Investor'),
                        subtitle: const Text(
                          'Use this for unnamed groups or minor investors',
                        ),
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
                            final investorIds = ctrl.investors
                                .map((i) => i.id)
                                .toSet();
                            final currentVal =
                                investorIds.contains(_selectedInvestorId)
                                ? _selectedInvestorId
                                : null;
                            final selectedInvestor = currentVal != null ? ctrl.investors.firstWhere((i) => i.id == currentVal) : null;

                            return FormField<String>(
                              initialValue: currentVal,
                              validator: (v) => _selectedInvestorId == null ? 'Please select an investor' : null,
                              builder: (formFieldState) {
                                return InkWell(
                                  onTap: () {
                                    final options = ctrl.investors.map((i) => {'value': i.id, 'label': i.name}).toList();
                                    _showSearchableDialog(
                                      title: 'Select Investor',
                                      options: options,
                                      currentValue: currentVal,
                                      onSelected: (val) {
                                        setState(() => _selectedInvestorId = val);
                                        formFieldState.didChange(val);
                                      },
                                    );
                                  },
                                  child: InputDecorator(
                                    decoration: InputDecoration(
                                      labelText: 'Investor *',
                                      prefixIcon: const Icon(Icons.person),
                                      errorText: formFieldState.errorText,
                                    ),
                                    child: Text(
                                      selectedInvestor?.name ?? 'Select Investor...',
                                      style: TextStyle(color: selectedInvestor != null ? AppColors.textPrimary : AppColors.textSecondary),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      const SizedBox(height: 16),

                      // Funding Round Dropdown
                      _isLoadingRounds
                          ? const LinearProgressIndicator()
                          : Builder(
                              builder: (context) {
                                final roundIds = _fundingRounds
                                    .map((r) => r['id']?.toString() ?? '')
                                    .toSet();
                                final currentVal =
                                    roundIds.contains(_selectedRoundId)
                                    ? _selectedRoundId
                                    : null;
                                final selectedRound = currentVal != null ? _fundingRounds.firstWhere((r) => (r['id']?.toString() ?? '') == currentVal) : null;
                                String getRoundName(Map<String, dynamic>? r) {
                                  if (r == null) return 'Select Funding Round...';
                                  final id = r['id']?.toString() ?? '';
                                  return (r['round_name'] ?? r['name'] ?? 'Round ${id.substring(0, id.length > 8 ? 8 : id.length)}').toString();
                                }
                                return FormField<String>(
                                  initialValue: currentVal,
                                  validator: (v) => _selectedRoundId == null ? 'Please select a funding round' : null,
                                  builder: (formFieldState) {
                                    return InkWell(
                                      onTap: () {
                                        final options = _fundingRounds.map((r) => {
                                          'value': r['id']?.toString() ?? '',
                                          'label': getRoundName(r)
                                        }).toList();
                                        _showSearchableDialog(
                                          title: 'Select Funding Round',
                                          options: options,
                                          currentValue: currentVal,
                                          onSelected: (val) {
                                            setState(() => _selectedRoundId = val);
                                            formFieldState.didChange(val);
                                          },
                                          onManage: _showManageFundingRoundsDialog,
                                        );
                                      },
                                      child: InputDecorator(
                                        decoration: InputDecoration(
                                          labelText: 'Funding Round *',
                                          prefixIcon: const Icon(Icons.cyclone),
                                          errorText: formFieldState.errorText,
                                        ),
                                        child: Text(
                                          getRoundName(selectedRound),
                                          style: TextStyle(color: selectedRound != null ? AppColors.textPrimary : AppColors.textSecondary),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),

                      const SizedBox(height: 32),
                      const Text(
                        'Financial Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
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
                              validator: (v) =>
                                  v!.trim().isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 120,
                            child: TextFormField(
                              controller: _currencyController,
                              decoration: const InputDecoration(
                                labelText: 'Currency *',
                              ),
                              validator: (v) =>
                                  v!.trim().isEmpty ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Status Dropdown
                      DropdownButtonFormField<String>(
                        initialValue: _statusOptions.contains(_selectedStatus)
                            ? _selectedStatus
                            : 'Pending',
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
                              color: _investDate != null
                                  ? AppColors.textPrimary
                                  : AppColors.textMuted,
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
                            _isSaving ? 'Updating...' : 'Update Investment',
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

  Future<void> _showSearchableDialog({
    required String title,
    required List<Map<String, String>> options,
    required String? currentValue,
    required ValueChanged<String?> onSelected,
    VoidCallback? onManage,
  }) async {
    final searchController = TextEditingController();
    List<Map<String, String>> filtered = List.from(options);

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  if (onManage != null)
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () {
                        Navigator.pop(context);
                        onManage();
                      },
                      tooltip: 'Manage Options',
                    ),
                ],
              ),
              contentPadding: const EdgeInsets.all(24),
              content: SizedBox(
                width: 400,
                height: 400,
                child: Column(
                  children: [
                    TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        labelText: 'Search',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (val) {
                        setDialogState(() {
                          if (val.isEmpty) {
                            filtered = List.from(options);
                          } else {
                            filtered = options
                                .where((opt) => (opt['label'] ?? '')
                                    .toLowerCase()
                                    .contains(val.toLowerCase()))
                                .toList();
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: filtered.isEmpty
                            ? const Center(child: Text('No results found.'))
                            : ListView.separated(
                                itemCount: filtered.length,
                                separatorBuilder: (context, index) => const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final item = filtered[index];
                                  final isSelected = item['value'] == currentValue;
                                  return ListTile(
                                    title: Text(item['label'] ?? ''),
                                    trailing: isSelected
                                        ? const Icon(Icons.check, color: AppColors.primary)
                                        : null,
                                    onTap: () {
                                      onSelected(item['value']);
                                      Navigator.pop(context);
                                    },
                                  );
                                },
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showManageFundingRoundsDialog() async {
    final newRoundController = TextEditingController();
    final controller = Provider.of<InvestmentsController>(context, listen: false);
    bool isLoadingAction = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Manage Funding Rounds', style: TextStyle(fontWeight: FontWeight.bold)),
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
                            controller: newRoundController,
                            decoration: const InputDecoration(
                              labelText: 'New Funding Round',
                              border: OutlineInputBorder(),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            enabled: !isLoadingAction,
                            onSubmitted: (val) async {
                              final name = val.trim();
                              if (name.isNotEmpty) {
                                setDialogState(() => isLoadingAction = true);
                                final success = await controller.createFundingRound(name);
                                if (success && mounted) {
                                  setState(() {
                                    _fundingRounds = controller.fundingRounds;
                                  });
                                  newRoundController.clear();
                                }
                                setDialogState(() => isLoadingAction = false);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: isLoadingAction
                              ? null
                              : () async {
                                  final name = newRoundController.text.trim();
                                  if (name.isNotEmpty) {
                                    setDialogState(() => isLoadingAction = true);
                                    final success = await controller.createFundingRound(name);
                                    if (success && mounted) {
                                      setState(() {
                                        _fundingRounds = controller.fundingRounds;
                                      });
                                      newRoundController.clear();
                                    }
                                    setDialogState(() => isLoadingAction = false);
                                  }
                                },
                          icon: isLoadingAction
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.add, size: 18),
                          label: const Text('Add'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (controller.fundingRounds.isEmpty)
                      const Text(
                        'No funding rounds available.',
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
                          itemCount: controller.fundingRounds.length,
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final round = controller.fundingRounds[index];
                            final id = round['id']?.toString() ?? '';
                            final name = (round['round_name'] ?? round['name'] ?? 'Round').toString();
                            return ListTile(
                              dense: true,
                              title: Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                                tooltip: 'Delete round',
                                onPressed: isLoadingAction
                                    ? null
                                    : () async {
                                        setDialogState(() => isLoadingAction = true);
                                        final success = await controller.deleteFundingRound(id);
                                        if (success && mounted) {
                                          setState(() {
                                            _fundingRounds = controller.fundingRounds;
                                            if (_selectedRoundId == id) {
                                              _selectedRoundId = null;
                                            }
                                          });
                                        }
                                        setDialogState(() => isLoadingAction = false);
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
