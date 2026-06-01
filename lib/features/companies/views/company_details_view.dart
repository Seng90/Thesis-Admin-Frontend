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
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  company.name,
                                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Chip(
                                label: Text(
                                  company.status,
                                  style: TextStyle(
                                    color: company.status == 'Approved' ? AppColors.success : (company.status == 'Pending' ? AppColors.warning : AppColors.error),
                                  ),
                                ),
                                backgroundColor: company.status == 'Approved' ? AppColors.successBg : (company.status == 'Pending' ? AppColors.warningBg : AppColors.errorBg),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const Divider(),
                          const SizedBox(height: 24),
                          
                          _buildDetailRow('INDUSTRY'.tr(context), company.industry),
                          _buildDetailRow('LOCATION'.tr(context), company.location),
                          _buildDetailRow('EMAIL'.tr(context), company.contactEmail),
                          _buildDetailRow('VIEWS'.tr(context), '${company.viewCount}'),
                          _buildDetailRow('Description', company.description),
                          _buildDetailRow('Website', company.websiteUrl ?? 'N/A'),
                          _buildDetailRow('Founded', company.foundedDate?.toString().split(' ')[0] ?? 'N/A'),
                          
                          const SizedBox(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => context.push('/companies/edit/${company.id}'),
                                icon: const Icon(Icons.edit),
                                label: Text('Edit Company'.tr(context)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
