import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:investrack_admin/features/investors/controllers/investors_controller.dart';
import 'package:investrack_admin/utils/constants.dart';
import 'package:investrack_admin/utils/localizations.dart';

class InvestorDetailsView extends StatefulWidget {
  final String investorId;

  const InvestorDetailsView({super.key, required this.investorId});

  @override
  State<InvestorDetailsView> createState() => _InvestorDetailsViewState();
}

class _InvestorDetailsViewState extends State<InvestorDetailsView> {
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final controller = Provider.of<InvestorsController>(context, listen: false);
      if (controller.investors.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.loadInvestors();
        });
      }
      _isInit = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Details'.tr(context)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Consumer<InvestorsController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          try {
            final investor = controller.investors.firstWhere((c) => c.id == widget.investorId);
            
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
                                  image: investor.logoUrl != null && investor.logoUrl!.isNotEmpty
                                      ? DecorationImage(
                                          image: NetworkImage(investor.logoUrl!),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: investor.logoUrl == null || investor.logoUrl!.isEmpty
                                    ? Center(
                                        child: Text(
                                          investor.name.substring(0, 1).toUpperCase(),
                                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary),
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            investor.name,
                                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryLight,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            investor.type.toUpperCase(),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    Row(
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: () => context.push('/investors/edit/${investor.id}'),
                                          icon: const Icon(Icons.edit, size: 16),
                                          label: Text('Edit Investor'.tr(context)),
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        if (investor.websiteUrl != null && investor.websiteUrl!.isNotEmpty)
                                          OutlinedButton.icon(
                                            onPressed: () {}, // would launch URL
                                            icon: const Icon(Icons.open_in_new, size: 16),
                                            label: const Text('Website'),
                                            style: OutlinedButton.styleFrom(
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Card(
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
                                    const Text('Contact Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 16),
                                    _buildInfoRow(
                                      Icons.contact_mail_outlined, 
                                      'Contact Info', 
                                      investor.contactInfo != null && investor.contactInfo!.isNotEmpty ? investor.contactInfo! : 'N/A'
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 1,
                            child: Card(
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
                                    const Text('At a Glance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 24),
                                    _buildGlanceItem('Type', investor.type, Icons.category_outlined),
                                    const Divider(height: 32),
                                    _buildGlanceItem('Created', investor.createdAt?.toString().split(' ')[0] ?? 'Unknown', Icons.access_time_outlined),
                                    const Divider(height: 32),
                                    _buildGlanceItem('Updated', investor.updatedAt?.toString().split(' ')[0] ?? 'Unknown', Icons.update_outlined),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          } catch (e) {
            return const Center(child: Text('Investor not found'));
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ],
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}
