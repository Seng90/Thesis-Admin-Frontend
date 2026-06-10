import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:investrack_admin/features/funding_rounds/controllers/investments_controller.dart';
import 'package:investrack_admin/features/revisions/controllers/revisions_controller.dart';
import 'package:investrack_admin/utils/constants.dart';

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
      Provider.of<InvestmentsController>(context, listen: false).fetchInvestments();
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
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
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
                    const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(controller.errorMessage!, style: const TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => controller.fetchInvestments(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (controller.investments.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.trending_up, size: 64, color: AppColors.textMuted),
                    const SizedBox(height: 16),
                    const Text('No investments yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    const Text('Add your first investment to get started.', style: TextStyle(color: AppColors.textMuted)),
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

            final filtered = controller.investments.where((inv) {
              if (_searchQuery.isEmpty) return true;
              final q = _searchQuery.toLowerCase();
              return inv.currency.toLowerCase().contains(q) ||
                  inv.amount.toString().contains(q) ||
                  inv.companyId.toLowerCase().contains(q) ||
                  inv.investorId.toLowerCase().contains(q);
            }).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Search bar
                SizedBox(
                  width: 300,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search investments...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
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
                                DataColumn(label: Text('AMOUNT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                DataColumn(label: Text('CURRENCY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                DataColumn(label: Text('DATE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                DataColumn(label: Text('COMPANY ID', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                DataColumn(label: Text('INVESTOR ID', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                DataColumn(label: Text('ACTIONS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                              ],
                              rows: filtered.map((inv) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text('\$${inv.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600))),
                                    DataCell(Text(inv.currency)),
                                    DataCell(Text(inv.investDate.toString().split(' ')[0])),
                                    DataCell(Text(inv.companyId.length > 8 ? '${inv.companyId.substring(0, 8)}...' : inv.companyId, style: const TextStyle(fontFamily: 'monospace', fontSize: 12))),
                                    DataCell(Text(inv.investorId.length > 8 ? '${inv.investorId.substring(0, 8)}...' : inv.investorId, style: const TextStyle(fontFamily: 'monospace', fontSize: 12))),
                                    DataCell(
                                      PopupMenuButton<String>(
                                        icon: const Icon(Icons.more_horiz, color: AppColors.textMuted),
                                        onSelected: (value) {
                                          if (value == 'view') {
                                            context.push('/investments/view/${inv.id}');
                                          } else if (value == 'edit') {
                                            context.push('/investments/edit/${inv.id}');
                                          } else if (value == 'delete') {
                                            showDialog(
                                              context: context,
                                              builder: (ctx) => AlertDialog(
                                                title: const Text('Delete Investment'),
                                                content: Text('Are you sure you want to delete this investment of \$${inv.amount}?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(ctx),
                                                    child: const Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(ctx);
                                                      final revController = Provider.of<RevisionsController>(context, listen: false);
                                                      revController.createRevision(
                                                        entityType: 'Investment',
                                                        entityId: inv.id,
                                                        proposedChanges: {'_action': 'delete'},
                                                      ).then((success) {
                                                        if (context.mounted) {
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            SnackBar(
                                                              content: Text(success ? 'Delete request submitted for review!' : (revController.errorMessage ?? 'Failed to submit.')),
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
                                        },
                                        itemBuilder: (context) => [
                                          const PopupMenuItem(value: 'view', child: Text('View Details')),
                                          const PopupMenuItem(value: 'edit', child: Text('Edit Investment')),
                                          const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
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
              }
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
