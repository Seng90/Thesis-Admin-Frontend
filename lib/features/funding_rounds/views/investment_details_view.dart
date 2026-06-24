import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:investrack_admin/features/funding_rounds/controllers/investments_controller.dart';
import 'package:investrack_admin/utils/constants.dart';

class InvestmentDetailsView extends StatefulWidget {
  final String investmentId;
  const InvestmentDetailsView({super.key, required this.investmentId});

  @override
  State<InvestmentDetailsView> createState() => _InvestmentDetailsViewState();
}

class _InvestmentDetailsViewState extends State<InvestmentDetailsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InvestmentsController>(
        context,
        listen: false,
      ).fetchInvestments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Details'),
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

          try {
            final inv = controller.investments.firstWhere(
              (i) => i.id == widget.investmentId,
            );

            return SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Card
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
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.attach_money,
                                    size: 32,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '${inv.amount} ${inv.currency}',
                                            style: const TextStyle(
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.successBg,
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: const Text(
                                            'COMPLETED',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.success,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Investment in ${inv.companyName ?? inv.companyId}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Row(
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: () => context.push(
                                            '/investments/edit/${inv.id}',
                                          ),
                                          icon: const Icon(
                                            Icons.edit,
                                            size: 16,
                                          ),
                                          label: const Text('Edit Investment'),
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
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
                      // Details Cards
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isSmallScreen = constraints.maxWidth < 600;
                          final card1 = Card(
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
                                  const Text(
                                    'Investment Details',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildInfoRow(
                                    Icons.business_outlined,
                                    'Company',
                                    inv.companyName ?? inv.companyId,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildInfoRow(
                                    Icons.person_outline,
                                    'Investor',
                                    inv.investorDisplayName,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildInfoRow(
                                    Icons.cyclone_outlined,
                                    'Funding Round',
                                    inv.roundName ?? inv.roundId,
                                  ),
                                  if (inv.referenceUrl != null &&
                                      inv.referenceUrl!.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    _buildInfoRow(
                                      Icons.link,
                                      'Reference URL',
                                      inv.referenceUrl!,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );

                          final card2 = Card(
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
                                  const Text(
                                    'At a Glance',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  _buildGlanceItem(
                                    'Date',
                                    inv.investDate.toIso8601String().split(
                                      'T',
                                    )[0],
                                    Icons.calendar_today_outlined,
                                  ),
                                  const Divider(height: 32),
                                  _buildGlanceItem(
                                    'Amount',
                                    inv.amount == 0
                                        ? 'Undisclosed'
                                        : '${inv.amount} ${inv.currency}',
                                    Icons.attach_money_outlined,
                                  ),
                                ],
                              ),
                            ),
                          );

                          if (isSmallScreen) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                card1,
                                const SizedBox(height: 24),
                                card2,
                              ],
                            );
                          } else {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 2, child: card1),
                                const SizedBox(width: 24),
                                Expanded(flex: 1, child: card2),
                              ],
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          } catch (e) {
            return const Center(child: Text('Investment not found'));
          }
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textMuted),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGlanceItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
