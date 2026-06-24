import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:investrack_admin/features/funding_rounds/controllers/investments_controller.dart';
import 'package:investrack_admin/features/revisions/controllers/revisions_controller.dart';
import 'package:investrack_admin/utils/constants.dart';
import 'package:investrack_admin/widgets/custom_logo_widget.dart';

class InvestmentSummaryDetailView extends StatefulWidget {
  final int summaryIndex;
  const InvestmentSummaryDetailView({super.key, required this.summaryIndex});

  @override
  State<InvestmentSummaryDetailView> createState() => _InvestmentSummaryDetailViewState();
}

class _InvestmentSummaryDetailViewState extends State<InvestmentSummaryDetailView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctrl = Provider.of<InvestmentsController>(context, listen: false);
      if (ctrl.summaries.isEmpty) {
        ctrl.fetchSummaries();
      }
    });
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'refunded':
        return AppColors.error;
      default:
        return AppColors.textMuted;
    }
  }

  Color _statusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppColors.successBg;
      case 'pending':
        return AppColors.warningBg;
      case 'refunded':
        return AppColors.errorBg;
      default:
        return AppColors.surface;
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Investment Round Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Consumer<InvestmentsController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (widget.summaryIndex >= controller.summaries.length) {
            return const Center(
              child: Text('Investment summary not found', style: TextStyle(color: AppColors.textSecondary)),
            );
          }

          final summary = controller.summaries[widget.summaryIndex];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Header Card ──
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomLogoWidget(
                              imageUrl: summary.companyLogoUrl,
                              fallbackName: summary.companyName,
                              size: 72,
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    summary.companyName,
                                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryLight,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          summary.roundName,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                      if (summary.companyIndustry.isNotEmpty) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppColors.surface,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            summary.companyIndustry,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Stats Cards ──
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isSmallScreen = constraints.maxWidth < 600;
                        final cards = [
                          _buildStatCard(
                            'Total Raised',
                            '\$${_formatAmount(summary.totalRaised)}',
                            Icons.account_balance_wallet_outlined,
                            AppColors.primary,
                            AppColors.primaryLight,
                          ),
                          _buildStatCard(
                            'Investors',
                            summary.investorCount.toString(),
                            Icons.people_outline,
                            AppColors.success,
                            AppColors.successBg,
                          ),
                          _buildStatCard(
                            'Currency',
                            summary.currency,
                            Icons.monetization_on_outlined,
                            AppColors.warning,
                            AppColors.warningBg,
                          ),
                        ];

                        if (isSmallScreen) {
                          return Column(
                            children: cards.map((c) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: c,
                            )).toList(),
                          );
                        }
                        return Row(
                          children: cards.asMap().entries.map((entry) {
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: entry.key > 0 ? 12 : 0,
                                  right: entry.key < cards.length - 1 ? 12 : 0,
                                ),
                                child: entry.value,
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // ── Investors Table ──
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Investor Breakdown',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () => context.push('/investments/add?companyId=${summary.companyId}&roundId=${summary.roundId}'),
                                  icon: const Icon(Icons.add, size: 16),
                                  label: const Text('Add Investment'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    textStyle: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columnSpacing: 24.0,
                                showCheckboxColumn: false,
                                columns: const [
                                  DataColumn(label: Text('INVESTOR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                  DataColumn(label: Text('AMOUNT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                  DataColumn(label: Text('CURRENCY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                  DataColumn(label: Text('DATE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                  DataColumn(label: Text('STATUS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                  DataColumn(label: Text('ACTIONS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                ],
                                rows: summary.investments.map((inv) {
                                  return DataRow(cells: [
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            inv.investorId != null ? Icons.person_outline : Icons.groups_outlined,
                                            size: 18,
                                            color: AppColors.textMuted,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            inv.investorDisplayName,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontStyle: inv.investorId == null ? FontStyle.italic : FontStyle.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    DataCell(Text(
                                      '\$${inv.amount.toStringAsFixed(2)}',
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    )),
                                    DataCell(Text(inv.currency)),
                                    DataCell(Text(
                                      '${inv.investDate.year}-${inv.investDate.month.toString().padLeft(2, '0')}-${inv.investDate.day.toString().padLeft(2, '0')}',
                                    )),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _statusBgColor(inv.status),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          inv.status.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: _statusColor(inv.status),
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit, color: AppColors.primary, size: 20),
                                            tooltip: 'Edit Investment',
                                            onPressed: () {
                                              context.push('/investments/edit/${inv.id}');
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                            tooltip: 'Delete Investment',
                                            onPressed: () {
                                              _showDeleteDialog(inv.id, inv.amount);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ]);
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDeleteDialog(String invId, double amount) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Investment'),
        content: Text('Are you sure you want to delete this investment of \$${amount.toStringAsFixed(2)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              final revController = Provider.of<RevisionsController>(context, listen: false);
              final messenger = ScaffoldMessenger.of(context);
              revController.createRevision(
                entityType: 'Investment',
                entityId: invId,
                proposedChanges: {'_action': 'delete'},
              ).then((success) {
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(success
                          ? 'Delete request submitted for review!'
                          : (revController.errorMessage ?? 'Failed to submit.')),
                      backgroundColor: success ? AppColors.success : AppColors.error,
                    ),
                  );
                }
              });
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color iconColor,
    Color bgColor,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  const SizedBox(height: 4),
                  Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
