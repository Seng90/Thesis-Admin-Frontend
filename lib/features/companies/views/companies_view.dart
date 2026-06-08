import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../controllers/companies_controller.dart';
import 'package:investrack_admin/utils/constants.dart';
import 'package:investrack_admin/utils/localizations.dart';

class CompaniesView extends StatefulWidget {
  const CompaniesView({super.key});

  @override
  State<CompaniesView> createState() => _CompaniesViewState();
}

class _CompaniesViewState extends State<CompaniesView> {
  final ScrollController _verticalScroll = ScrollController();
  final ScrollController _horizontalScroll = ScrollController();
  String _searchQuery = '';
  String _statusFilter = 'All';

  @override
  void dispose() {
    _verticalScroll.dispose();
    _horizontalScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Pre-evaluate translations to avoid Provider.of inside callbacks
    final strAddCompany = 'Add Company'.tr(context);
    final strCompanies = 'Companies'.tr(context);
    final strCompany = 'COMPANY'.tr(context);
    final strIndustry = 'INDUSTRY'.tr(context);
    final strLocation = 'LOCATION'.tr(context);
    final strStatus = 'STATUS'.tr(context);
    final strActions = 'ACTIONS'.tr(context);
    final strApprove = 'Approve'.tr(context);
    final strViewDetails = 'View Details'.tr(context);
    final strEdit = 'Edit Company'.tr(context);
    final strDelete = 'Delete'.tr(context);
    final strCancel = 'Cancel'.tr(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(strCompanies),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 32.0),
            child: ElevatedButton.icon(
              onPressed: () => context.push('/companies/add'),
              icon: const Icon(Icons.add, size: 18),
              label: Text(strAddCompany),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
        child: Consumer<CompaniesController>(
          builder: (context, controller, child) {
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(controller.errorMessage!, style: const TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => controller.loadCompanies(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (controller.companies.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.business, size: 64, color: AppColors.textMuted),
                    const SizedBox(height: 16),
                    const Text('No companies yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    const Text('Add your first company to get started.', style: TextStyle(color: AppColors.textMuted)),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => context.push('/companies/add'),
                      icon: const Icon(Icons.add),
                      label: Text(strAddCompany),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search by name or industry...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    DropdownButton<String>(
                      value: _statusFilter,
                      items: ['All', 'Approved', 'Pending', 'Rejected'].map((status) {
                        return DropdownMenuItem(value: status, child: Text(status));
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _statusFilter = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      var filteredList = controller.companies.where((c) {
                        final matchesSearch = _searchQuery.isEmpty || c.name.toLowerCase().contains(_searchQuery.toLowerCase()) || c.industry.toLowerCase().contains(_searchQuery.toLowerCase());
                        final matchesStatus = _statusFilter == 'All' || c.status == _statusFilter;
                        return matchesSearch && matchesStatus;
                      }).toList();

                      if (filteredList.isEmpty) {
                        return const Center(child: Text('No companies match your filters.'));
                      }

                      return Card(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Scrollbar(
                            controller: _horizontalScroll,
                            thumbVisibility: true,
                            child: SingleChildScrollView(
                              controller: _horizontalScroll,
                              scrollDirection: Axis.horizontal,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: constraints.maxHeight,
                                  minWidth: MediaQuery.of(context).size.width - 64,
                                ),
                                child: Scrollbar(
                                  controller: _verticalScroll,
                                  thumbVisibility: true,
                                  child: SingleChildScrollView(
                                    controller: _verticalScroll,
                                    scrollDirection: Axis.vertical,
                                    child: DataTable(
                                      columnSpacing: 16.0,
                                      showCheckboxColumn: false,
                                      columns: [
                                        DataColumn(label: Text(strCompany)),
                                        DataColumn(label: Text(strIndustry)),
                                        DataColumn(label: Text(strLocation)),
                                        DataColumn(label: Text(strStatus)),
                                        DataColumn(label: Text(strActions)),
                                      ],
                                      rows: filteredList.map((company) {
                                        final isApproved = company.status == 'Approved';
                                        final isPending = company.status == 'Pending';
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(company.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                            Text(company.contactEmail, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                          ],
                                        )
                                      ),
                                      DataCell(Text(company.industry)),
                                      DataCell(Text(company.location)),
                                      DataCell(
                                        Chip(
                                          label: Text(
                                            company.status,
                                            style: TextStyle(
                                              color: isApproved ? AppColors.success : isPending ? AppColors.warning : AppColors.error,
                                              fontSize: 12,
                                            ),
                                          ),
                                          backgroundColor: isApproved ? AppColors.successBg : isPending ? AppColors.warningBg : AppColors.errorBg,
                                        ),
                                      ),
                                      DataCell(
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            PopupMenuButton<String>(
                                              icon: const Icon(Icons.more_horiz, color: AppColors.textMuted),
                                              onSelected: (value) {
                                                if (value == 'approve') {
                                                  controller.updateCompanyStatus(company.id, 'Approved');
                                                } else if (value == 'view') {
                                                  context.push('/companies/view/${company.id}');
                                                } else if (value == 'edit') {
                                                  context.push('/companies/edit/${company.id}');
                                                } else if (value == 'delete') {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) => AlertDialog(
                                                      title: const Text('Delete Company'),
                                                      content: Text('Are you sure you want to delete "${company.name}"?'),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () => Navigator.pop(context),
                                                          child: Text(strCancel),
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            controller.deleteCompany(company.id);
                                                            Navigator.pop(context);
                                                          },
                                                          child: Text(strDelete, style: const TextStyle(color: Colors.red)),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }
                                              },
                                              itemBuilder: (context) => [
                                                if (isPending)
                                                  PopupMenuItem(
                                                    value: 'approve',
                                                    child: Text(strApprove, style: const TextStyle(color: AppColors.primary)),
                                                  ),
                                                PopupMenuItem(
                                                  value: 'view',
                                                  child: Text(strViewDetails),
                                                ),
                                                PopupMenuItem(
                                                  value: 'edit',
                                                  child: Text(strEdit),
                                                ),
                                                PopupMenuItem(
                                                  value: 'delete',
                                                  child: Text(strDelete, style: const TextStyle(color: Colors.red)),
                                                ),
                                              ],
                                            ),
                                          ],
                                        )
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }
            ),
          ),
        ],
      );
    },
  ),
),
    );
  }
}
