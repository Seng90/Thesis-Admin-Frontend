import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:investrack_admin/features/funding_rounds/controllers/investments_controller.dart';
import 'package:investrack_admin/utils/constants.dart';
import 'package:investrack_admin/widgets/custom_logo_widget.dart';

class InvestmentsView extends StatefulWidget {
  const InvestmentsView({super.key});

  @override
  State<InvestmentsView> createState() => _InvestmentsViewState();
}

class _InvestmentsViewState extends State<InvestmentsView> {
  final ScrollController _verticalScroll = ScrollController();
  final ScrollController _horizontalScroll = ScrollController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InvestmentsController>(
        context,
        listen: false,
      ).fetchSummaries();
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
        title: const Text('Investments'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 32.0),
            child: ElevatedButton.icon(
              onPressed: () => context.push('/investments/add'),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Investment'),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
        child: Consumer<InvestmentsController>(
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
                      onPressed: () => controller.fetchSummaries(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (controller.summaries.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.trending_up,
                      size: 64,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No investments yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Add your first investment to get started.',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => context.push('/investments/add'),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Investment'),
                    ),
                  ],
                ),
              );
            }

            final filtered = controller.summaries.where((s) {
              if (_searchQuery.isEmpty) return true;
              final q = _searchQuery.toLowerCase();
              return s.companyName.toLowerCase().contains(q) ||
                  s.roundName.toLowerCase().contains(q) ||
                  s.totalRaised.toString().contains(q);
            }).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Search bar
                SizedBox(
                  width: 300,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by company or round...',
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
                                            'COMPANY',
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
                                            'TOTAL RAISED',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'INVESTORS',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'DATE',
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
                                      rows: filtered.asMap().entries.map((
                                        entry,
                                      ) {
                                        final idx = entry.key;
                                        final summary = entry.value;
                                        return DataRow(
                                          cells: [
                                            DataCell(
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  CustomLogoWidget(
                                                    imageUrl:
                                                        summary.companyLogoUrl,
                                                    fallbackName:
                                                        summary.companyName,
                                                    size: 32,
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Text(
                                                    summary.companyName,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
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
                                                  summary.roundName,
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
                                                summary.totalRaised == 0
                                                    ? 'Undisclosed'
                                                    : '\$${_formatAmount(summary.totalRaised)}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14,
                                                  color:
                                                      summary.totalRaised == 0
                                                      ? AppColors.textMuted
                                                      : AppColors.textPrimary,
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                '${summary.investorCount} investor${summary.investorCount != 1 ? 's' : ''}',
                                                style: const TextStyle(
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                summary.earliestDate != null
                                                    ? '${summary.earliestDate!.year}-${summary.earliestDate!.month.toString().padLeft(2, '0')}-${summary.earliestDate!.day.toString().padLeft(2, '0')}'
                                                    : '-',
                                                style: const TextStyle(
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              ElevatedButton.icon(
                                                onPressed: () {
                                                  context.push(
                                                    '/investments/summary/$idx',
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

  String _formatAmount(double amount) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)}B';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(2);
  }
}
