import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../controllers/packages_controller.dart';
import 'package:investrack_admin/features/revisions/controllers/revisions_controller.dart';
import 'package:investrack_admin/utils/constants.dart';
import 'package:investrack_admin/utils/localizations.dart';

class PackagesView extends StatefulWidget {
  const PackagesView({super.key});

  @override
  State<PackagesView> createState() => _PackagesViewState();
}

class _PackagesViewState extends State<PackagesView> {
  final ScrollController _verticalScroll = ScrollController();
  final ScrollController _horizontalScroll = ScrollController();
  String _searchQuery = '';
  bool _isUSD = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<PackagesController>(context, listen: false);
      if (controller.packages.isEmpty && !controller.isLoading) {
        controller.loadPackages();
      }
    });
  }

  @override
  void dispose() {
    _verticalScroll.dispose();
    _horizontalScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strPackages = 'Packages'.tr(context);
    final strAddPackage = 'Add Package'.tr(context);
    final strPackage = 'PACKAGE'.tr(context);
    final strPrice = 'PRICE'.tr(context);
    final strPurchases = 'PURCHASES'.tr(context);
    final strActions = 'ACTIONS'.tr(context);
    final strViewDetails = 'View Details'.tr(context);
    final strEdit = 'Edit'.tr(context);
    final strDelete = 'Delete'.tr(context);
    final strCancel = 'Cancel'.tr(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(strPackages),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            tooltip: 'Refresh',
            onPressed: () {
              context.read<PackagesController>().loadPackages();
            },
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 32.0),
            child: ElevatedButton.icon(
              onPressed: () => context.push('/packages/add'),
              icon: const Icon(Icons.add, size: 18),
              label: Text(strAddPackage),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
        child: Consumer<PackagesController>(
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
                          hintText: 'Search by package name...',
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
                    ToggleButtons(
                      isSelected: [_isUSD, !_isUSD],
                      borderRadius: BorderRadius.circular(8),
                      constraints: const BoxConstraints(minHeight: 48),
                      onPressed: (index) {
                        setState(() {
                          _isUSD = index == 0;
                        });
                      },
                      children: const [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'USD',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'KIP',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      var filteredList = controller.packages.where((p) {
                        return _searchQuery.isEmpty ||
                            p.name.toLowerCase().contains(
                              _searchQuery.toLowerCase(),
                            );
                      }).toList();

                      if (filteredList.isEmpty) {
                        return const Center(
                          child: Text('No packages match your search.'),
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
                                  minWidth: constraints.maxWidth,
                                ),
                                child: Scrollbar(
                                  controller: _verticalScroll,
                                  thumbVisibility: true,
                                  child: SingleChildScrollView(
                                    controller: _verticalScroll,
                                    scrollDirection: Axis.vertical,
                                    child: DataTable(
                                      columnSpacing: 16.0,
                                      dataRowMaxHeight: 70,
                                      dataRowMinHeight: 50,
                                      showCheckboxColumn: false,
                                      columns: [
                                        DataColumn(label: Text(strPackage)),
                                        DataColumn(label: Text(strPrice)),
                                        DataColumn(label: const Text('Duration (Days)')),
                                        DataColumn(label: Text(strPurchases)),
                                        DataColumn(label: Text(strActions)),
                                      ],
                                      rows: filteredList.map((pkg) {
                                        return DataRow(
                                          cells: [
                                            DataCell(
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    pkg.name,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  SizedBox(
                                                    width: 200,
                                                    child: Tooltip(
                                                      message: pkg.features,
                                                      child: Text(
                                                        pkg.features,
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color: AppColors
                                                              .textSecondary,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                pkg.price == 0
                                                    ? 'Free'
                                                    : _isUSD
                                                    ? '\$${pkg.price.toStringAsFixed(2)}'
                                                    : '${(pkg.price * 25000).toStringAsFixed(0)} LAK',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                pkg.durationDays != null && pkg.durationDays! > 0
                                                    ? '${pkg.durationDays} Days'
                                                    : 'Lifetime',
                                                style: const TextStyle(
                                                  color: AppColors.textSecondary,
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.primaryLight,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  '${pkg.purchaseCount}',
                                                  style: const TextStyle(
                                                    color: AppColors.primary,
                                                    fontWeight: FontWeight.bold,
                                                  ),
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
                                                          '/packages/view/${pkg.id}',
                                                        );
                                                      } else if (value ==
                                                          'edit') {
                                                        context.push(
                                                          '/packages/edit/${pkg.id}',
                                                        );
                                                      } else if (value ==
                                                          'delete') {
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) => AlertDialog(
                                                            title: const Text(
                                                              'Delete Package',
                                                            ),
                                                            content: Text(
                                                              'Are you sure you want to delete "${pkg.name}"?',
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
                                                                            'Package',
                                                                        entityId:
                                                                            pkg.id,
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
