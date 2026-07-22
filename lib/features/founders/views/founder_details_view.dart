import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:investrack_admin/features/founders/controllers/founders_controller.dart';
import 'package:investrack_admin/features/revisions/controllers/revisions_controller.dart';
import 'package:investrack_admin/utils/constants.dart';
import 'package:investrack_admin/widgets/custom_logo_widget.dart';
import 'package:investrack_admin/features/companies/models/company_model.dart';

class FounderDetailsView extends StatefulWidget {
  final String founderId;

  const FounderDetailsView({super.key, required this.founderId});

  @override
  State<FounderDetailsView> createState() => _FounderDetailsViewState();
}

class _FounderDetailsViewState extends State<FounderDetailsView> {
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final controller = Provider.of<FoundersController>(
        context,
        listen: false,
      );
      if (controller.founders.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.fetchFounders();
        });
      }
      _isInit = true;
    }
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
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            tooltip: 'Delete Founder',
            onPressed: () {
              final controller = Provider.of<FoundersController>(
                context,
                listen: false,
              );
              String founderName = 'this founder';
              try {
                final founder = controller.founders.firstWhere(
                  (f) => f.id == widget.founderId,
                );
                founderName = founder.nameEn;
              } catch (_) {}
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Founder'),
                  content: Text(
                    'Are you sure you want to delete "$founderName"?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        final revController = Provider.of<RevisionsController>(
                          context,
                          listen: false,
                        );
                        revController
                            .createRevision(
                              entityType: 'Founder',
                              entityId: widget.founderId,
                              proposedChanges: {'_action': 'delete'},
                            )
                            .then((success) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      success
                                          ? 'Delete request submitted for review!'
                                          : (revController.errorMessage ??
                                                'Failed to submit.'),
                                    ),
                                    backgroundColor: success
                                        ? AppColors.success
                                        : AppColors.error,
                                  ),
                                );
                              }
                            });
                      },
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Consumer<FoundersController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          try {
            final founder = controller.founders.firstWhere(
              (f) => f.id == widget.founderId,
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
                              CustomLogoWidget(
                                imageUrl: founder.avatarUrl,
                                fallbackName: founder.nameEn.isNotEmpty ? founder.nameEn : '?',
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
                                            '${founder.nameLa} | ${founder.nameEn}',
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
                                            'ACTIVE',
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
                                    const Text(
                                      'Founder Profile',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Row(
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: () => context.push(
                                            '/founders/edit/${founder.id}',
                                          ),
                                          icon: const Icon(
                                            Icons.edit,
                                            size: 16,
                                          ),
                                          label: const Text('Edit Founder'),
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        if (founder.linkedinUrl != null &&
                                            founder.linkedinUrl!.isNotEmpty)
                                          OutlinedButton.icon(
                                            onPressed:
                                                () {}, // would launch URL
                                            icon: const Icon(
                                              Icons.open_in_new,
                                              size: 16,
                                            ),
                                            label: const Text('LinkedIn'),
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
                                    'About',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    (founder.bio != null &&
                                            founder.bio!.isNotEmpty)
                                        ? founder.bio!
                                        : 'No bio provided.',
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
                                    Icons.link_outlined,
                                    'LinkedIn',
                                    (founder.linkedinUrl != null &&
                                            founder.linkedinUrl!.isNotEmpty)
                                        ? founder.linkedinUrl!
                                        : 'N/A',
                                  ),
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
                                    'Created',
                                    founder.createdAt.toString().split(' ')[0],
                                    Icons.access_time_outlined,
                                  ),
                                  const Divider(height: 32),
                                  _buildGlanceItem(
                                    'Updated',
                                    founder.updatedAt.toString().split(' ')[0],
                                    Icons.update_outlined,
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
                      
                      if (founder.companies.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _buildCompaniesSection(founder.companies),
                      ],
                    ],
                  ),
                ),
              ),
            );
          } catch (e) {
            return const Center(child: Text('Founder not found'));
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

  Widget _buildCompaniesSection(List<Company> companies) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Founded Companies',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: companies.map((company) {
            return InkWell(
              onTap: () => context.push('/companies/view/${company.id}'),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 250,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    CustomLogoWidget(
                      imageUrl: company.logoUrl,
                      fallbackName: company.name,
                      size: 40,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            company.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (company.industry.isNotEmpty)
                            Text(
                              company.industry,
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
