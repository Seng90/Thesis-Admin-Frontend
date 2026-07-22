import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:investrack_admin/features/companies/controllers/companies_controller.dart';
import 'package:investrack_admin/utils/constants.dart';
import 'package:investrack_admin/utils/localizations.dart';
import 'package:investrack_admin/widgets/custom_logo_widget.dart';
import 'package:investrack_admin/features/founders/models/founder_model.dart';
import 'package:investrack_admin/features/investors/models/investor_model.dart';

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
      final controller = Provider.of<CompaniesController>(
        context,
        listen: false,
      );
      if (controller.companies.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.loadCompanies();
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
      body: Consumer<CompaniesController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          try {
            final company = controller.companies.firstWhere(
              (c) => c.id == widget.companyId,
            );

            return SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1000),
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
                              CustomLogoWidget(
                                imageUrl: company.logoUrl,
                                fallbackName: company.name,
                                size: 80,
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
                                            company.name,
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
                                            color: company.status == 'Approved'
                                                ? AppColors.successBg
                                                : (company.status == 'Pending'
                                                      ? AppColors.warningBg
                                                      : AppColors.errorBg),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Text(
                                            company.status.toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color:
                                                  company.status == 'Approved'
                                                  ? AppColors.success
                                                  : (company.status == 'Pending'
                                                        ? AppColors.warning
                                                        : AppColors.error),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${company.industry} • ${company.location}',
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
                                            '/companies/edit/${company.id}',
                                          ),
                                          icon: const Icon(
                                            Icons.edit,
                                            size: 16,
                                          ),
                                          label: Text(
                                            'Edit Company'.tr(context),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        if (company.websiteUrl != null &&
                                            company.websiteUrl!.isNotEmpty)
                                          OutlinedButton.icon(
                                            onPressed:
                                                () {}, // would launch URL
                                            icon: const Icon(
                                              Icons.open_in_new,
                                              size: 16,
                                            ),
                                            label: const Text('Website'),
                                            style: OutlinedButton.styleFrom(
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
                          final isSmallScreen = constraints.maxWidth < 800;

                          // -- Card 1: About & Contact --
                          final cardAbout = Card(
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
                                    'About',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    company.description.isNotEmpty
                                        ? company.description
                                        : 'No description provided.',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      height: 1.5,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  const Text(
                                    'Contact Information',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildInfoRow(
                                    Icons.email_outlined,
                                    'Email',
                                    company.contactEmail.isNotEmpty
                                        ? company.contactEmail
                                        : 'N/A',
                                  ),
                                  const SizedBox(height: 12),
                                  _buildInfoRow(
                                    Icons.location_on_outlined,
                                    'Location',
                                    company.location,
                                  ),
                                  if (company.headquartersAddress != null &&
                                      company
                                          .headquartersAddress!
                                          .isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    _buildInfoRow(
                                      Icons.business_outlined,
                                      'Headquarters',
                                      company.headquartersAddress!,
                                    ),
                                  ],
                                  const SizedBox(height: 24),
                                  const Text(
                                    'Social Media',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  if (company.facebookUrl != null &&
                                      company.facebookUrl!.isNotEmpty) ...[
                                    _buildInfoRow(
                                      Icons.facebook,
                                      'Facebook',
                                      company.facebookUrl!,
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                  if (company.linkedinUrl != null &&
                                      company.linkedinUrl!.isNotEmpty) ...[
                                    _buildInfoRow(
                                      Icons.work,
                                      'LinkedIn',
                                      company.linkedinUrl!,
                                    ),
                                  ],
                                  if ((company.facebookUrl == null ||
                                          company.facebookUrl!.isEmpty) &&
                                      (company.linkedinUrl == null ||
                                          company.linkedinUrl!.isEmpty))
                                    const Text(
                                      'No social media links provided.',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 13,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );

                          // -- Card 2: At a Glance --
                          final cardGlance = Card(
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
                                    'Operating Status',
                                    company.operatingStatus,
                                    Icons.power_settings_new,
                                  ),
                                  const Divider(height: 24),
                                  _buildGlanceItem(
                                    'Employees',
                                    company.employeeCount ?? 'N/A',
                                    Icons.people_outline,
                                  ),
                                  const Divider(height: 24),
                                  _buildGlanceItem(
                                    'Branches',
                                    company.branchCount?.toString() ?? 'N/A',
                                    Icons.store_outlined,
                                  ),
                                  const Divider(height: 24),
                                  _buildGlanceItem(
                                    'Views',
                                    '${company.viewCount}',
                                    Icons.remove_red_eye_outlined,
                                  ),
                                  const Divider(height: 24),
                                  _buildGlanceItem(
                                    'Founded',
                                    company.foundedDate?.toString().split(
                                          ' ',
                                        )[0] ??
                                        'Unknown',
                                    Icons.calendar_today_outlined,
                                  ),
                                ],
                              ),
                            ),
                          );

                          // -- Card 3: Legal & Tax --
                          final cardLegal = Card(
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
                                    'Legal & Tax',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  _buildGlanceItem(
                                    'Registration No.',
                                    company.registrationNumber?.isNotEmpty ==
                                            true
                                        ? company.registrationNumber!
                                        : 'N/A',
                                    Icons.assignment_outlined,
                                  ),
                                  const Divider(height: 24),
                                  _buildGlanceItem(
                                    'Tax ID',
                                    company.taxId?.isNotEmpty == true
                                        ? company.taxId!
                                        : 'N/A',
                                    Icons.receipt_long_outlined,
                                  ),
                                ],
                              ),
                            ),
                          );

                          // -- Card 4: Highlights --
                          final cardHighlights = Card(
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
                                    'Business Highlights',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  const Text(
                                    'Key Products',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  if (company.keyProducts.isEmpty)
                                    const Text(
                                      'No products listed.',
                                      style: TextStyle(
                                        color: AppColors.textMuted,
                                      ),
                                    )
                                  else
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: company.keyProducts
                                          .map(
                                            (p) => Chip(
                                              label: Text(p),
                                              backgroundColor:
                                                  AppColors.primaryLight,
                                              side: BorderSide.none,
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  const SizedBox(height: 24),
                                  const Text(
                                    'Key Partners',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  if (company.keyPartners.isEmpty)
                                    const Text(
                                      'No partners listed.',
                                      style: TextStyle(
                                        color: AppColors.textMuted,
                                      ),
                                    )
                                  else
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: company.keyPartners
                                          .map(
                                            (p) => Chip(
                                              label: Text(p),
                                              backgroundColor:
                                                  AppColors.surface,
                                              side: const BorderSide(
                                                color: AppColors.border,
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                ],
                              ),
                            ),
                          );

                          if (isSmallScreen) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                cardAbout,
                                const SizedBox(height: 24),
                                cardHighlights,
                                const SizedBox(height: 24),
                                cardGlance,
                                const SizedBox(height: 16),
                                cardLegal,
                                if (company.founders.isNotEmpty) ...[
                                  const SizedBox(height: 24),
                                  _buildFoundersSection(company.founders),
                                ],
                                if (company.investors.isNotEmpty) ...[
                                  const SizedBox(height: 24),
                                  _buildInvestorsSection(company.investors),
                                ],
                              ],
                            );
                          } else {
                            return Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(flex: 2, child: cardAbout),
                                    const SizedBox(width: 24),
                                    Expanded(flex: 1, child: cardGlance),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(flex: 2, child: cardHighlights),
                                    const SizedBox(width: 24),
                                    Expanded(flex: 1, child: cardLegal),
                                  ],
                                ),
                                if (company.founders.isNotEmpty) ...[
                                  const SizedBox(height: 32),
                                  _buildFoundersSection(company.founders),
                                ],
                                if (company.investors.isNotEmpty) ...[
                                  const SizedBox(height: 32),
                                  _buildInvestorsSection(company.investors),
                                ],
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
            return const Center(child: Text('Company not found'));
          }
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
              const SizedBox(height: 2),
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

  Widget _buildFoundersSection(List<Founder> founders) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Founders',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: founders.map((founder) {
            return InkWell(
              onTap: () => context.push('/founders/view/${founder.id}'),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 250,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CustomLogoWidget(
                      imageUrl: founder.avatarUrl,
                      fallbackName: founder.nameEn.isNotEmpty ? founder.nameEn : '?',
                      size: 48,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            founder.nameEn,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            founder.role ?? 'Founder',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildInvestorsSection(List<Investor> investors) {
    // A company might have multiple investments from the same investor. We should deduplicate.
    final uniqueInvestors = investors.fold<Map<String, Investor>>({}, (map, inv) {
      map[inv.id] = inv;
      return map;
    }).values.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Investors',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: uniqueInvestors.map((investor) {
            return InkWell(
              onTap: () => context.push('/investors/view/${investor.id}'),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 250,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CustomLogoWidget(
                      imageUrl: investor.logoUrl,
                      fallbackName: investor.name,
                      size: 48,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            investor.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            investor.type,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
