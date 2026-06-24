import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../controllers/fundraising_posts_controller.dart';
import 'package:investrack_admin/utils/constants.dart';
import 'package:investrack_admin/utils/localizations.dart';
import 'package:investrack_admin/widgets/custom_logo_widget.dart';

class FundraisingPostsView extends StatefulWidget {
  const FundraisingPostsView({super.key});

  @override
  State<FundraisingPostsView> createState() => _FundraisingPostsViewState();
}

class _FundraisingPostsViewState extends State<FundraisingPostsView> {
  final ScrollController _verticalScroll = ScrollController();
  final ScrollController _horizontalScroll = ScrollController();
  String _searchQuery = '';
  String _statusFilter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FundraisingPostsController>().loadPosts();
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
      appBar: AppBar(title: Text('Fundraising'.tr(context))),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
        child: Consumer<FundraisingPostsController>(
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
                      onPressed: () => controller.loadPosts(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (controller.posts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.campaign,
                      size: 64,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No fundraising posts yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            // Filtering
            var filteredPosts = controller.posts.where((p) {
              final matchesSearch =
                  p.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  p.companyId.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  );
              final matchesStatus =
                  _statusFilter == 'All' || p.status == _statusFilter;
              return matchesSearch && matchesStatus;
            }).toList();

            final currencyFormatter = NumberFormat.currency(
              symbol: '\$',
              decimalDigits: 0,
            );
            final dateFormatter = DateFormat('MMM dd, yyyy');

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search and Filter Bar
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search by title...',
                          prefixIcon: const Icon(
                            Icons.search,
                            color: AppColors.textSecondary,
                          ),
                          filled: true,
                          fillColor: Theme.of(context).cardColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).cardColor.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _statusFilter,
                            isExpanded: true,
                            items: ['All', 'Active', 'Closed', 'Pending'].map((
                              status,
                            ) {
                              return DropdownMenuItem(
                                value: status,
                                child: Text(status),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _statusFilter = val;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Data Table
                Expanded(
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Scrollbar(
                            controller: _horizontalScroll,
                            thumbVisibility: true,
                            notificationPredicate: (notif) => notif.depth == 1,
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
                                            'TITLE',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'ROUND',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'TARGET',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'DEADLINE',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'STATUS',
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
                                      rows: filteredPosts.map((post) {
                                        return DataRow(
                                          cells: [
                                            DataCell(
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  CustomLogoWidget(
                                                    imageUrl: post.coverUrl,
                                                    fallbackName: post.title,
                                                    size: 32,
                                                  ),
                                                  const SizedBox(width: 12),
                                                  SizedBox(
                                                    width: 140,
                                                    child: Text(
                                                      post.title,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            DataCell(
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.primaryLight,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  post.roundType,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.primary,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                post.targetAmountUsd == 0
                                                    ? 'Undisclosed'
                                                    : currencyFormatter.format(
                                                        post.targetAmountUsd,
                                                      ),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14,
                                                  color:
                                                      post.targetAmountUsd == 0
                                                      ? AppColors.textMuted
                                                      : AppColors.textPrimary,
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                dateFormatter.format(
                                                  post.deadline,
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: post.status == 'Active'
                                                      ? AppColors.success
                                                            .withValues(
                                                              alpha: 0.1,
                                                            )
                                                      : (post.status == 'Hidden'
                                                            ? AppColors.warning
                                                                  .withValues(
                                                                    alpha: 0.1,
                                                                  )
                                                            : AppColors
                                                                  .textMuted
                                                                  .withValues(
                                                                    alpha: 0.1,
                                                                  )),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Text(
                                                  post.status.toUpperCase(),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        post.status == 'Active'
                                                        ? AppColors.success
                                                        : (post.status ==
                                                                  'Hidden'
                                                              ? AppColors
                                                                    .warning
                                                              : AppColors
                                                                    .textMuted),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              ElevatedButton.icon(
                                                onPressed: () {
                                                  context.push(
                                                    '/raises/view/${post.slug}',
                                                  );
                                                },
                                                icon: const Icon(
                                                  Icons.visibility_outlined,
                                                  size: 16,
                                                ),
                                                label: const Text(
                                                  'View Details',
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 8,
                                                      ),
                                                  textStyle: const TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
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
