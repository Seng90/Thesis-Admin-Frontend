import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:investrack_admin/features/members/controllers/members_controller.dart';
import 'package:investrack_admin/features/packages/controllers/packages_controller.dart';
import 'package:investrack_admin/utils/constants.dart';
import 'package:investrack_admin/utils/localizations.dart';
import 'package:investrack_admin/widgets/custom_logo_widget.dart';

class MemberDetailsView extends StatefulWidget {
  final String memberId;

  const MemberDetailsView({super.key, required this.memberId});

  @override
  State<MemberDetailsView> createState() => _MemberDetailsViewState();
}

class _MemberDetailsViewState extends State<MemberDetailsView> {
  bool _isInit = false;
  List<Map<String, dynamic>> _managedCompanies = [];
  bool _isLoadingCompanies = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final controller = Provider.of<MembersController>(context, listen: false);
      if (controller.members.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.loadMembers();
        });
      }
      _fetchManagedCompanies();
      _isInit = true;
    }
  }

  Future<void> _fetchManagedCompanies() async {
    setState(() => _isLoadingCompanies = true);
    final controller = Provider.of<MembersController>(context, listen: false);
    final companies = await controller.getManagedCompanies(widget.memberId);
    if (mounted) {
      setState(() {
        _managedCompanies = companies;
        _isLoadingCompanies = false;
      });
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
      body: Consumer<MembersController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          try {
            final member = controller.members.firstWhere(
              (m) => m.id == widget.memberId,
            );
            final isActive = member.status == 'Active';

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
                                    member.username
                                        .substring(0, 1)
                                        .toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
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
                                            member.username,
                                            style: const TextStyle(
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: AppColors.primaryLight,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                member.role.toUpperCase(),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: isActive
                                                    ? AppColors.successBg
                                                    : AppColors.errorBg,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                member.status.toUpperCase(),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: isActive
                                                      ? AppColors.success
                                                      : AppColors.error,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      member.email,
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
                                            '/members/edit/${member.id}',
                                          ),
                                          icon: const Icon(
                                            Icons.edit,
                                            size: 16,
                                          ),
                                          label: Text(
                                            'Edit Member'.tr(context),
                                          ),
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
                                    'Account Information',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildInfoRow(
                                    Icons.email_outlined,
                                    'Email Address',
                                    member.email,
                                  ),
                                  const SizedBox(height: 12),
                                  Consumer<PackagesController>(
                                    builder:
                                        (context, packagesController, child) {
                                          String packageName = 'Lifetime';
                                          if (member.packageId != null) {
                                            final package = packagesController
                                                .packages
                                                .where(
                                                  (p) =>
                                                      p.id == member.packageId,
                                                )
                                                .firstOrNull;
                                            packageName =
                                                package?.name ??
                                                member.packageId!;
                                          }
                                          return _buildInfoRow(
                                            Icons.card_membership_outlined,
                                            'Package',
                                            packageName,
                                          );
                                        },
                                  ),
                                  const SizedBox(height: 12),
                                  _buildInfoRow(
                                    Icons.event_busy_outlined,
                                    'Expiry Date',
                                    member.expiryDate?.toString().split(
                                          ' ',
                                        )[0] ??
                                        'Lifetime',
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
                                    'Timeline',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  _buildGlanceItem(
                                    'Created',
                                    member.createdAt?.toString().split(
                                          ' ',
                                        )[0] ??
                                        'Unknown',
                                    Icons.access_time_outlined,
                                  ),
                                  const Divider(height: 32),
                                  _buildGlanceItem(
                                    'Updated',
                                    member.updatedAt?.toString().split(
                                          ' ',
                                        )[0] ??
                                        'Unknown',
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
                                if (member.role.toLowerCase() == 'founder') ...[
                                  const SizedBox(height: 24),
                                  _buildManagedCompaniesCard(),
                                ],
                              ],
                            );
                          } else {
                            return Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(flex: 2, child: card1),
                                    const SizedBox(width: 24),
                                    Expanded(flex: 1, child: card2),
                                  ],
                                ),
                                if (member.role.toLowerCase() == 'founder') ...[
                                  const SizedBox(height: 24),
                                  _buildManagedCompaniesCard(),
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
            return const Center(child: Text('Member not found'));
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

  Widget _buildManagedCompaniesCard() {
    return Card(
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
              'Managed Companies',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            if (_isLoadingCompanies)
              const Center(child: CircularProgressIndicator())
            else if (_managedCompanies.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'No companies assigned.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _managedCompanies.length,
                separatorBuilder: (context, index) => const Divider(height: 24),
                itemBuilder: (context, index) {
                  final company = _managedCompanies[index];
                  return Row(
                    children: [
                      CustomLogoWidget(
                        imageUrl: company['logo_url'],
                        fallbackName: company['name'] ?? 'Unknown',
                        size: 40,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          company['name'] ?? 'Unknown',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
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
