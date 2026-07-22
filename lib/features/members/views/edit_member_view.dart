import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:investrack_admin/features/members/controllers/members_controller.dart';
import 'package:investrack_admin/features/packages/controllers/packages_controller.dart';
import 'package:investrack_admin/features/revisions/controllers/revisions_controller.dart';
import 'package:investrack_admin/features/companies/controllers/companies_controller.dart';

import 'package:investrack_admin/utils/localizations.dart';
import 'package:investrack_admin/widgets/custom_logo_widget.dart';

class EditMemberView extends StatefulWidget {
  final String memberId;

  const EditMemberView({super.key, required this.memberId});

  @override
  State<EditMemberView> createState() => _EditMemberViewState();
}

class _EditMemberViewState extends State<EditMemberView> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late String _status;
  late String _role;
  String? _packageId;
  DateTime? _expiryDate;

  bool _isInit = false;
  List<String> _initialManagedCompanyIds = [];
  List<String> _selectedCompanyIds = [];
  bool _isLoadingCompanies = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final controller = Provider.of<MembersController>(context, listen: false);
      final existingMember = controller.members.firstWhere(
        (m) => m.id == widget.memberId,
      );

      _usernameController = TextEditingController(
        text: existingMember.username,
      );
      _emailController = TextEditingController(text: existingMember.email);
      _status = existingMember.status;
      final currentRole = existingMember.role.toLowerCase();
      _role = ['founder', 'user', 'membership'].contains(currentRole)
          ? currentRole
          : 'user';
      _packageId = existingMember.packageId;
      _expiryDate = existingMember.expiryDate;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<PackagesController>(context, listen: false).loadPackages();
        Provider.of<CompaniesController>(
          context,
          listen: false,
        ).loadCompanies();
      });

      _fetchManagedCompanies();
      _isInit = true;
    }
  }

  Future<void> _fetchManagedCompanies() async {
    setState(() => _isLoadingCompanies = true);
    final controller = Provider.of<MembersController>(context, listen: false);
    final companies = await controller.getManagedCompanies(widget.memberId);
    if (mounted) {
      setState(() {
        _initialManagedCompanyIds = companies
            .map((c) => c['id'].toString())
            .toList();
        _selectedCompanyIds = List.from(_initialManagedCompanyIds);
        _isLoadingCompanies = false;
      });
    }
  }

  void _showCompaniesDialog() {
    final companiesCtrl = Provider.of<CompaniesController>(
      context,
      listen: false,
    );
    final allCompanies = companiesCtrl.companies;
    List<String> tempSelected = List.from(_selectedCompanyIds);
    String searchQuery = '';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final filteredCompanies = allCompanies
                .where(
                  (c) =>
                      c.name.toLowerCase().contains(searchQuery.toLowerCase()),
                )
                .toList();
            return AlertDialog(
              title: const Text('Select Managed Companies'),
              content: SizedBox(
                width: 400,
                height: 400,
                child: Column(
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Search Companies',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setDialogState(() {
                          searchQuery = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredCompanies.length,
                        itemBuilder: (context, index) {
                          final company = filteredCompanies[index];
                          return CheckboxListTile(
                            secondary: CustomLogoWidget(
                              imageUrl: company.logoUrl,
                              fallbackName: company.name,
                              size: 32,
                            ),
                            title: Text(company.name),
                            value: tempSelected.contains(company.id),
                            onChanged: (checked) {
                              setDialogState(() {
                                if (checked == true) {
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
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedCompanyIds = tempSelected;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final controller = Provider.of<MembersController>(context, listen: false);
      final existingMember = controller.members.firstWhere(
        (m) => m.id == widget.memberId,
      );

      Map<String, dynamic> changes = {};

      if (_usernameController.text != existingMember.username) {
        changes['username'] = _usernameController.text;
      }
      if (_emailController.text != existingMember.email) {
        changes['email'] = _emailController.text;
      }
      if (_status != existingMember.status) {
        changes['status'] = _status;
      }
      if (_role.toLowerCase() != existingMember.role.toLowerCase()) {
        changes['role'] = _role;
      }
      if (_packageId != existingMember.packageId) {
        changes['package_id'] = _packageId;
      }
      if (_expiryDate != existingMember.expiryDate) {
        changes['expiry_date'] = _expiryDate?.toIso8601String();
      }

      // Check if managed companies changed
      bool companiesChanged = false;
      if (_initialManagedCompanyIds.length != _selectedCompanyIds.length) {
        companiesChanged = true;
      } else {
        for (var id in _selectedCompanyIds) {
          if (!_initialManagedCompanyIds.contains(id)) {
            companiesChanged = true;
            break;
          }
        }
      }

      if (companiesChanged) {
        changes['companyIds'] = _selectedCompanyIds;
      }

      if (changes.isNotEmpty) {
        final revisionsController = Provider.of<RevisionsController>(
          context,
          listen: false,
        );
        revisionsController.createRevision(
          entityType: 'Member',
          entityId: widget.memberId,
          proposedChanges: changes,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Edit submitted for review!'.tr(context, listen: false))),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No changes detected.'.tr(context, listen: false))),
        );
      }

      context.pop();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _expiryDate) {
      setState(() {
        _expiryDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final packagesController = Provider.of<PackagesController>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Member'.tr(context)),
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
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username'.tr(context),
                        ),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email'.tr(context),
                        ),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        key: ValueKey('status_$_status'),
                        initialValue: _status,
                        decoration: InputDecoration(
                          labelText: 'Status'.tr(context),
                        ),
                        items: ['Active', 'Blocked'].map((String val) {
                          return DropdownMenuItem(value: val, child: Text(val));
                        }).toList(),
                        onChanged: (newVal) {
                          if (newVal != null) {
                            setState(() {
                              _status = newVal;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        key: ValueKey('role_$_role'),
                        initialValue: _role,
                        decoration: InputDecoration(
                          labelText: 'Role'.tr(context),
                        ),
                        items: ['user', 'membership', 'founder'].map((
                          String val,
                        ) {
                          return DropdownMenuItem(
                            value: val,
                            child: Text(val.toUpperCase()),
                          );
                        }).toList(),
                        onChanged: (newVal) {
                          if (newVal != null) {
                            setState(() {
                              _role = newVal;
                              if (_role == 'user') {
                                _packageId = null;
                              }
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      Builder(
                        builder: (context) {
                          final validPackageId = packagesController.packages.any((p) => p.id == _packageId) ? _packageId : null;
                          return DropdownButtonFormField<String?>(
                            key: ValueKey('package_$validPackageId'),
                            initialValue: validPackageId,
                            decoration: InputDecoration(
                              labelText: 'Package'.tr(context),
                            ),
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text('None (Lifetime)'),
                              ),
                              ...packagesController.packages.map((pkg) {
                                return DropdownMenuItem(
                                  value: pkg.id,
                                  child: Text(pkg.name),
                                );
                              }),
                            ],
                            onChanged: (newVal) {
                              setState(() {
                                _packageId = newVal;
                                if (_packageId == null) {
                                  if (_role == 'membership') {
                                    _role = 'user';
                                  }
                                }
                              });
                            },
                          );
                        }
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('Expiry Date'.tr(context)),
                        subtitle: Text(
                          _expiryDate != null
                              ? _expiryDate!.toString().split(' ')[0]
                              : 'Lifetime',
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () => _selectDate(context),
                      ),
                      if (_role.toLowerCase() == 'founder') ...[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 24),
                            const Divider(),
                            const SizedBox(height: 16),
                            const Text(
                              'Managed Companies',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (_isLoadingCompanies)
                              const Center(child: CircularProgressIndicator())
                            else
                              Consumer<CompaniesController>(
                                builder: (context, companiesCtrl, child) {
                                  if (companiesCtrl.isLoading) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                  if (companiesCtrl.companies.isEmpty) {
                                    return const Text(
                                      'No companies available.',
                                    );
                                  }
                                  final selectedCompanies = companiesCtrl
                                      .companies
                                      .where(
                                        (c) =>
                                            _selectedCompanyIds.contains(c.id),
                                      )
                                      .toList();

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (selectedCompanies.isEmpty)
                                        const Padding(
                                          padding: EdgeInsets.only(
                                            bottom: 16.0,
                                          ),
                                          child: Text(
                                            'No companies assigned.',
                                            style: TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                        )
                                      else
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 16.0,
                                          ),
                                          child: ListView.separated(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount: selectedCompanies.length,
                                            separatorBuilder:
                                                (context, index) =>
                                                    const Divider(height: 16),
                                            itemBuilder: (context, index) {
                                              final company =
                                                  selectedCompanies[index];
                                              return Row(
                                                children: [
                                                  CustomLogoWidget(
                                                    imageUrl: company.logoUrl,
                                                    fallbackName: company.name,
                                                    size: 32,
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Text(
                                                      company.name,
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                        ),
                                      OutlinedButton.icon(
                                        onPressed: _showCompaniesDialog,
                                        icon: const Icon(Icons.business),
                                        label: const Text('Select Companies'),
                                      ),
                                    ],
                                  );
                                },
                              ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _saveForm,
                        child: Text('Save Changes'.tr(context)),
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
