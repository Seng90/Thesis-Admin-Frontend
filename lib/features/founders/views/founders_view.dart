import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:investrack_admin/features/founders/controllers/founders_controller.dart';
import 'package:investrack_admin/features/revisions/controllers/revisions_controller.dart';
import 'package:investrack_admin/utils/constants.dart';
import 'package:investrack_admin/widgets/custom_logo_widget.dart';

class FoundersView extends StatefulWidget {
  const FoundersView({super.key});

  @override
  State<FoundersView> createState() => _FoundersViewState();
}

class _FoundersViewState extends State<FoundersView> {
  final ScrollController _verticalScroll = ScrollController();
  final ScrollController _horizontalScroll = ScrollController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FoundersController>(context, listen: false).fetchFounders();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Founders'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 32.0),
            child: ElevatedButton.icon(
              onPressed: () => context.push('/founders/add'),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Founder'),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
        child: Consumer<FoundersController>(
          builder: (context, controller, child) {
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      controller.errorMessage!,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => controller.fetchFounders(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (controller.founders.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.people,
                      size: 64,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No founders yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Add your first founder to get started.',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => context.push('/founders/add'),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Founder'),
                    ),
                  ],
                ),
              );
            }

            final filtered = controller.founders.where((f) {
              if (_searchQuery.isEmpty) return true;
              final q = _searchQuery.toLowerCase();
              return f.nameEn.toLowerCase().contains(q) ||
                  f.nameLa.toLowerCase().contains(q) ||
                  (f.bio ?? '').toLowerCase().contains(q);
            }).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Search bar
                SizedBox(
                  width: 300,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search founders...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 12,
                      ),
                    ),
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                ),
                const SizedBox(height: 16),
                // Table
                Expanded(
                  child: Card(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return ClipRRect(
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
                                      columnSpacing: 24.0,
                                      showCheckboxColumn: false,
                                      columns: const [
                                        DataColumn(
                                          label: Text(
                                            'NAME',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'ROLE',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'BIO',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'LINKEDIN',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'ACTIONS',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                      rows: filtered.map((founder) {
                                        return DataRow(
                                          cells: [
                                            DataCell(
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  CustomLogoWidget(
                                                    imageUrl: null,
                                                    fallbackName:
                                                        founder.nameEn,
                                                    size: 32,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    '${founder.nameLa} | ${founder.nameEn}',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                founder.role ?? 'N/A',
                                                style: const TextStyle(
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                (founder.bio ?? 'N/A').length >
                                                        40
                                                    ? '${(founder.bio ?? 'N/A').substring(0, 40)}...'
                                                    : (founder.bio ?? 'N/A'),
                                                style: const TextStyle(
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                founder.linkedinUrl ?? 'N/A',
                                                style: const TextStyle(
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              PopupMenuButton<String>(
                                                icon: const Icon(
                                                  Icons.more_horiz,
                                                  color: AppColors.textMuted,
                                                ),
                                                onSelected: (value) {
                                                  if (value == 'view') {
                                                    context.push(
                                                      '/founders/view/${founder.id}',
                                                    );
                                                  } else if (value == 'edit') {
                                                    context.push(
                                                      '/founders/edit/${founder.id}',
                                                    );
                                                  } else if (value ==
                                                      'delete') {
                                                    showDialog(
                                                      context: context,
                                                      builder: (ctx) => AlertDialog(
                                                        title: const Text(
                                                          'Delete Founder',
                                                        ),
                                                        content: Text(
                                                          'Are you sure you want to delete "${founder.nameEn}"?',
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                  ctx,
                                                                ),
                                                            child: const Text(
                                                              'Cancel',
                                                            ),
                                                          ),
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                ctx,
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
                                                                        'Founder',
                                                                    entityId:
                                                                        founder
                                                                            .id,
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
                                                                                : (revController.errorMessage ??
                                                                                      'Failed to submit.'),
                                                                          ),
                                                                          backgroundColor:
                                                                              success
                                                                              ? AppColors.success
                                                                              : AppColors.error,
                                                                        ),
                                                                      );
                                                                    }
                                                                  });
                                                            },
                                                            child: const Text(
                                                              'Delete',
                                                              style: TextStyle(
                                                                color:
                                                                    Colors.red,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }
                                                },
                                                itemBuilder: (context) => [
                                                  const PopupMenuItem(
                                                    value: 'view',
                                                    child: Text('View Details'),
                                                  ),
                                                  const PopupMenuItem(
                                                    value: 'edit',
                                                    child: Text('Edit Founder'),
                                                  ),
                                                  const PopupMenuItem(
                                                    value: 'delete',
                                                    child: Text(
                                                      'Delete',
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                      ),
                                                    ),
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
                        );
                      },
                    ),
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
