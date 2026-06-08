import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:investrack_admin/features/companies/controllers/companies_controller.dart';
import 'package:investrack_admin/utils/constants.dart';
import 'package:investrack_admin/utils/localizations.dart';

class CompanyDetailsView extends StatefulWidget {
  final String companyId;

  const CompanyDetailsView({super.key, required this.companyId});

  @override
  State<CompanyDetailsView> createState() => _CompanyDetailsViewState();
}

class _CompanyDetailsViewState extends State<CompanyDetailsView> {
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      // Ensure data is loaded
      final controller = Provider.of<CompaniesController>(context, listen: false);
      if (controller.companies.isEmpty) {
        controller.loadCompanies();
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
      body: Consumer<CompaniesController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          try {
            final company = controller.companies.firstWhere((c) => c.id == widget.companyId);
            
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
                                child: Center(
                                  child: Text(
                                    company.name.substring(0, 1).toUpperCase(),
                                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary),
                                  ),
                                ),
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
                                            company.name,
                                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: company.status == 'Approved' ? AppColors.successBg : (company.status == 'Pending' ? AppColors.warningBg : AppColors.errorBg),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            company.status.toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: company.status == 'Approved' ? AppColors.success : (company.status == 'Pending' ? AppColors.warning : AppColors.error),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${company.industry} • ${company.location}',
                                      style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
                                    ),
                                    const SizedBox(height: 24),
                                    Row(
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: () => context.push('/companies/edit/${company.id}'),
                                          icon: const Icon(Icons.edit, size: 16),
                                          label: Text('Edit Company'.tr(context)),
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        if (company.websiteUrl != null)
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
                                    const Text('About', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 16),
                                    Text(
                                      company.description.isNotEmpty ? company.description : 'No description provided.',
                                      style: const TextStyle(fontSize: 15, height: 1.5, color: AppColors.textSecondary),
                                    ),
                                    const SizedBox(height: 32),
                                    const Text('Contact Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 16),
                                    _buildInfoRow(Icons.email_outlined, 'Email', company.contactEmail.isNotEmpty ? company.contactEmail : 'N/A'),
                                    const SizedBox(height: 12),
                                    _buildInfoRow(Icons.location_on_outlined, 'Location', company.location),
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
                                    _buildGlanceItem('Views', '${company.viewCount}', Icons.remove_red_eye_outlined),
                                    const Divider(height: 32),
                                    _buildGlanceItem('Founded', company.foundedDate?.toString().split(' ')[0] ?? 'Unknown', Icons.calendar_today_outlined),
                                    const Divider(height: 32),
                                    _buildGlanceItem('Created', company.createdAt?.toString().split(' ')[0] ?? 'Unknown', Icons.access_time_outlined),
                                    const Divider(height: 32),
                                    _buildGlanceItem('Updated', company.updatedAt?.toString().split(' ')[0] ?? 'Unknown', Icons.update_outlined),
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
            return const Center(child: Text('Company not found'));
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
