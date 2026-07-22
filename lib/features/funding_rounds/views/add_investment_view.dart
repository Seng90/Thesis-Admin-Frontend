import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:investrack_admin/features/revisions/controllers/revisions_controller.dart';
import 'package:investrack_admin/features/companies/controllers/companies_controller.dart';
import 'package:investrack_admin/features/investors/controllers/investors_controller.dart';
import 'package:investrack_admin/utils/constants.dart';
import 'package:investrack_admin/features/funding_rounds/controllers/investments_controller.dart';

class InvestmentEntry {
  bool isOtherInvestor = false;
  String? investorId;
  final TextEditingController customNameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController currencyController = TextEditingController(
    text: 'USD',
  );
  final TextEditingController referenceUrlController = TextEditingController();
  String status = 'Pending';

  void dispose() {
    customNameController.dispose();
    amountController.dispose();
    currencyController.dispose();
    referenceUrlController.dispose();
  }
}

class AddInvestmentView extends StatefulWidget {
  final String? initialCompanyId;
  final String? initialRoundId;

  const AddInvestmentView({
    super.key,
    this.initialCompanyId,
    this.initialRoundId,
  });

  @override
  State<AddInvestmentView> createState() => _AddInvestmentViewState();
}

class _AddInvestmentViewState extends State<AddInvestmentView> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _investDate;
  bool _isSaving = false;

  String? _selectedCompanyId;
  String? _selectedRoundId;

  final List<InvestmentEntry> _entries = [];

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
    _selectedCompanyId = widget.initialCompanyId;
    _selectedRoundId = widget.initialRoundId;
    _entries.add(InvestmentEntry()); // Add one entry by default

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDependencies();
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

  @override
  void dispose() {
    for (var entry in _entries) {
      entry.dispose();
    }
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

  void _addEntry() {
    setState(() {
      _entries.add(InvestmentEntry());
    });
  }

  void _removeEntry(int index) {
    if (_entries.length > 1) {
      setState(() {
        _entries[index].dispose();
        _entries.removeAt(index);
      });
    }
  }

  double _calculateTotal() {
    double total = 0;
    for (var entry in _entries) {
      total += double.tryParse(entry.amountController.text.trim()) ?? 0;
    }
    return total;
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_investDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an investment date')),
      );
      return;
    }
    if (_selectedCompanyId == null || _selectedRoundId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select Company and Funding Round'),
        ),
      );
      return;
    }

    // Validate entries
    for (var entry in _entries) {
      if (!entry.isOtherInvestor && entry.investorId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please select an Investor or choose "Other / Anonymous" for all entries',
            ),
          ),
        );
        return;
      }
    }

    setState(() => _isSaving = true);
    final revisionsController = Provider.of<RevisionsController>(
      context,
      listen: false,
    );

    bool allSuccess = true;
    for (var entry in _entries) {
      Map<String, dynamic> proposedChanges = {
        'amount': double.tryParse(entry.amountController.text.trim()) ?? 0.0,
        'currency': entry.currencyController.text.trim(),
        'company_id': _selectedCompanyId,
        'round_id': _selectedRoundId,
        'invest_date': _investDate!.toIso8601String(),
        'status': entry.status,
      };

      if (entry.referenceUrlController.text.trim().isNotEmpty) {
        proposedChanges['reference_url'] = entry.referenceUrlController.text
            .trim();
      }

      if (entry.isOtherInvestor) {
        proposedChanges['investor_id'] = null;
        proposedChanges['custom_investor_name'] =
            entry.customNameController.text.trim().isNotEmpty
            ? entry.customNameController.text.trim()
            : 'Others';
      } else {
        proposedChanges['investor_id'] = entry.investorId;
      }

      final success = await revisionsController.createRevision(
        entityType: 'Investment',
        entityId: null,
        proposedChanges: proposedChanges,
      );

      if (!success) {
        allSuccess = false;
      }
    }

    if (mounted) {
      setState(() => _isSaving = false);
      if (!allSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Some investments failed to submit.'),
            backgroundColor: AppColors.error,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Investments submitted for review!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    }
  }

  Widget _buildEntryCard(InvestmentEntry entry, int index) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Investor #${index + 1}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              if (_entries.length > 1)
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: AppColors.error,
                    size: 20,
                  ),
                  onPressed: () => _removeEntry(index),
                  tooltip: 'Remove Investor',
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Investor Toggle
          SwitchListTile(
            title: const Text('Other / Anonymous Investor'),
            subtitle: const Text(
              'Use this for unnamed groups or minor investors',
            ),
            value: entry.isOtherInvestor,
            activeThumbColor: AppColors.primary,
            contentPadding: EdgeInsets.zero,
            onChanged: (v) {
              setState(() {
                entry.isOtherInvestor = v;
                if (v) entry.investorId = null;
              });
            },
          ),
          const SizedBox(height: 8),

          // Investor Dropdown OR Custom Name Field
          if (entry.isOtherInvestor)
            TextFormField(
              controller: entry.customNameController,
              decoration: const InputDecoration(
                labelText: 'Group / Custom Name',
                hintText: 'e.g. Friends & Family, Angel Syndicate',
                prefixIcon: Icon(Icons.groups),
              ),
            )
          else
            Consumer<InvestorsController>(
              builder: (context, ctrl, _) {
                final currentVal =
                    ctrl.investors.map((i) => i.id).contains(entry.investorId)
                    ? entry.investorId
                    : null;
                final selectedInvestor = currentVal != null ? ctrl.investors.firstWhere((i) => i.id == currentVal) : null;
                return FormField<String>(
                  initialValue: currentVal,
                  validator: (v) => entry.investorId == null ? 'Please select an investor' : null,
                  builder: (formFieldState) {
                    return InkWell(
                      onTap: () {
                        final options = ctrl.investors.map((i) => {'value': i.id, 'label': i.name}).toList();
                        _showSearchableDialog(
                          title: 'Select Investor',
                          options: options,
                          currentValue: currentVal,
                          onSelected: (val) {
                            setState(() => entry.investorId = val);
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

          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: entry.amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount *',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                  onChanged: (v) =>
                      setState(() {}), // Trigger total recalculation
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 120,
                child: TextFormField(
                  controller: entry.currencyController,
                  decoration: const InputDecoration(labelText: 'Currency *'),
                  validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Status Dropdown
          DropdownButtonFormField<String>(
            initialValue: entry.status,
            decoration: const InputDecoration(
              labelText: 'Status',
              prefixIcon: Icon(Icons.flag_outlined),
            ),
            items: _statusOptions
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (v) => setState(() => entry.status = v!),
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: entry.referenceUrlController,
            decoration: const InputDecoration(
              labelText: 'Reference URL (Optional)',
              prefixIcon: Icon(Icons.link),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isPreFilled =
        widget.initialCompanyId != null && widget.initialRoundId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isPreFilled ? 'Add Investor to Round' : 'Add Funding Round',
        ),
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
                padding: const EdgeInsets.all(32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        isPreFilled
                            ? 'Round Details'
                            : 'New Funding Round Details',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Company Dropdown
                      Consumer<CompaniesController>(
                        builder: (context, ctrl, _) {
                          final currentVal =
                              ctrl.companies
                                  .map((c) => c.id)
                                  .contains(_selectedCompanyId)
                              ? _selectedCompanyId
                              : null;
                          final selectedCompany = currentVal != null ? ctrl.companies.firstWhere((c) => c.id == currentVal) : null;
                          return FormField<String>(
                            initialValue: currentVal,
                            validator: (v) => _selectedCompanyId == null ? 'Please select a company' : null,
                            builder: (formFieldState) {
                              return InkWell(
                                onTap: isPreFilled ? null : () {
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

                      // Funding Round Dropdown
                      _isLoadingRounds
                          ? const LinearProgressIndicator()
                          : Builder(
                              builder: (context) {
                                final currentVal =
                                    _fundingRounds
                                        .map((r) => r['id']?.toString())
                                        .contains(_selectedRoundId)
                                    ? _selectedRoundId
                                    : null;
                                final selectedRound = currentVal != null ? _fundingRounds.firstWhere((r) => r['id']?.toString() == currentVal) : null;
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
                                      onTap: isPreFilled ? null : () {
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

                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32.0),
                        child: Divider(),
                      ),

                      const Text(
                        'Investors Breakdown',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // List of entries
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _entries.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) =>
                            _buildEntryCard(_entries[index], index),
                      ),
                      const SizedBox(height: 16),

                      // Add Investor Button
                      OutlinedButton.icon(
                        onPressed: _addEntry,
                        icon: const Icon(Icons.person_add),
                        label: const Text('Add Another Investor'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Total Summary
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Raised:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              '\$${_calculateTotal().toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Submit Button
                      SizedBox(
                        height: 54,
                        child: ElevatedButton.icon(
                          onPressed: _isSaving ? null : _saveForm,
                          icon: _isSaving
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.check_circle_outline),
                          label: Text(
                            _isSaving
                                ? 'Submitting...'
                                : 'Submit ${_entries.length} Investment${_entries.length > 1 ? 's' : ''}',
                            style: const TextStyle(fontSize: 16),
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
