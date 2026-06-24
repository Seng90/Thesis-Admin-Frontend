import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../controllers/investors_controller.dart';
import 'package:investrack_admin/features/revisions/controllers/revisions_controller.dart';
import 'package:investrack_admin/utils/constants.dart';
import 'package:investrack_admin/utils/localizations.dart';
import 'package:investrack_admin/widgets/custom_logo_widget.dart';

class InvestorsView extends StatefulWidget {
  const InvestorsView({super.key});

  @override
  State<InvestorsView> createState() => _InvestorsViewState();
}

class _InvestorsViewState extends State<InvestorsView> {
  final ScrollController _verticalScroll = ScrollController();
  final ScrollController _horizontalScroll = ScrollController();
  String _searchQuery = '';
  String _typeFilter = 'All';

  @override
  void dispose() {
    _verticalScroll.dispose();
    _horizontalScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strInvestors = 'Investors'.tr(context);
    final strAddInvestor = 'Add Investor'.tr(context);
    final strInvestor = 'INVESTOR'.tr(context);
    final strType = 'TYPE'.tr(context);
    final strWebsite = 'WEBSITE'.tr(context);
    final strActions = 'ACTIONS'.tr(context);
    final strViewDetails = 'View Details'.tr(context);
    final strEdit = 'Edit'.tr(context);
    final strDelete = 'Delete'.tr(context);
    final strCancel = 'Cancel'.tr(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(strInvestors),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 32.0),
            child: ElevatedButton.icon(
              onPressed: () => context.push('/investors/add'),
              icon: const Icon(Icons.add, size: 18),
              label: Text(strAddInvestor),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
        child: Consumer<InvestorsController>(
          builder: (context, controller, child) {
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.errorMessage != null) {
              return Center(child: Text(controller.errorMessage!));
            }

            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search by name...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
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
                      value: _typeFilter,
                      items:
                          [
                            'All',
                            'VC',
                            'Angel',
                            'PE',
                            'Corporate',
                            'Accelerator',
                            'Syndicate',
                            'Other',
                          ].map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _typeFilter = value;
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
                      var filteredList = controller.investors.where((i) {
                        final matchesSearch =
                            _searchQuery.isEmpty ||
                            i.name.toLowerCase().contains(
                              _searchQuery.toLowerCase(),
                            );
                        final matchesType =
                            _typeFilter == 'All' || i.type == _typeFilter;
                        return matchesSearch && matchesType;
                      }).toList();

                      if (filteredList.isEmpty) {
                        return const Center(
                          child: Text('No investors match your filters.'),
                        );
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
                                  minWidth:
                                      MediaQuery.of(context).size.width - 64,
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
                                        DataColumn(label: Text(strInvestor)),
                                        DataColumn(label: Text(strType)),
                                        DataColumn(label: Text(strWebsite)),
                                        DataColumn(label: Text(strActions)),
                                      ],
                                      rows: filteredList.map((investor) {
                                        return DataRow(
                                          cells: [
                                            DataCell(
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  CustomLogoWidget(
                                                    imageUrl: investor.logoUrl,
                                                    fallbackName: investor.name,
                                                    size: 32,
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        investor.name,
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                      Text(
                                                        investor.contactInfo ??
                                                            '',
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color: AppColors
                                                              .textSecondary,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            DataCell(
                                              Chip(
                                                label: Text(
                                                  investor.type,
                                                  style: const TextStyle(
                                                    color: AppColors.primary,
                                                  ),
                                                ),
                                                backgroundColor:
                                                    AppColors.primaryLight,
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                investor.websiteUrl ?? 'N/A',
                                                style: const TextStyle(
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  PopupMenuButton<String>(
                                                    icon: const Icon(
                                                      Icons.more_horiz,
                                                      color:
                                                          AppColors.textMuted,
                                                    ),
                                                    onSelected: (value) {
                                                      if (value == 'view') {
                                                        context.push(
                                                          '/investors/view/${investor.id}',
                                                        );
                                                      } else if (value ==
                                                          'edit') {
                                                        context.push(
                                                          '/investors/edit/${investor.id}',
                                                        );
                                                      } else if (value ==
                                                          'delete') {
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) => AlertDialog(
                                                            title: const Text(
                                                              'Delete Investor',
                                                            ),
                                                            content: Text(
                                                              'Are you sure you want to delete "${investor.name}"?',
                                                            ),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () =>
                                                                    Navigator.pop(
                                                                      context,
                                                                    ),
                                                                child: Text(
                                                                  strCancel,
                                                                ),
                                                              ),
                                                              TextButton(
                                                                onPressed: () {
                                                                  Navigator.pop(
                                                                    context,
                                                                  );
                                                                  final revController =
                                                                      Provider.of<
                                                                        RevisionsController
                                                                      >(
                                                                        context,
                                                                        listen:
                                                                            false,
                                                                      );
                                                                  revController
                                                                      .createRevision(
                                                                        entityType:
                                                                            'Investor',
                                                                        entityId:
                                                                            investor.id,
                                                                        proposedChanges: {
                                                                          '_action':
                                                                              'delete',
                                                                        },
                                                                      )
                                                                      .then((
                                                                        success,
                                                                      ) {
                                                                        if (context
                                                                            .mounted) {
                                                                          ScaffoldMessenger.of(
                                                                            context,
                                                                          ).showSnackBar(
                                                                            SnackBar(
                                                                              content: Text(
                                                                                success
                                                                                    ? 'Delete request submitted for review!'
                                                                                    : 'Failed to submit.',
                                                                              ),
                                                                              backgroundColor: success
                                                                                  ? AppColors.success
                                                                                  : AppColors.error,
                                                                            ),
                                                                          );
                                                                        }
                                                                      });
                                                                },
                                                                child: Text(
                                                                  strDelete,
                                                                  style: const TextStyle(
                                                                    color: Colors
                                                                        .red,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      }
                                                    },
                                                    itemBuilder: (context) => [
                                                      PopupMenuItem(
                                                        value: 'view',
                                                        child: Text(
                                                          strViewDetails,
                                                        ),
                                                      ),
                                                      PopupMenuItem(
                                                        value: 'edit',
                                                        child: Text(strEdit),
                                                      ),
                                                      PopupMenuItem(
                                                        value: 'delete',
                                                        child: Text(
                                                          strDelete,
                                                          style:
                                                              const TextStyle(
                                                                color:
                                                                    Colors.red,
                                                              ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
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
                    },
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
