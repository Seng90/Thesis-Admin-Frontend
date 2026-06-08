import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:investrack_admin/features/members/controllers/members_controller.dart';
import 'package:investrack_admin/utils/constants.dart';
import 'package:investrack_admin/utils/localizations.dart';

class MemberDetailsView extends StatefulWidget {
  final String memberId;

  const MemberDetailsView({super.key, required this.memberId});

  @override
  State<MemberDetailsView> createState() => _MemberDetailsViewState();
}

class _MemberDetailsViewState extends State<MemberDetailsView> {
  bool _isInit = false;

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
      body: Consumer<MembersController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          try {
            final member = controller.members.firstWhere((m) => m.id == widget.memberId);
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
                                    member.username.substring(0, 1).toUpperCase(),
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
                                            member.username,
                                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: isActive ? AppColors.successBg : AppColors.errorBg,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            member.status.toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: isActive ? AppColors.success : AppColors.error,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      member.email,
                                      style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
                                    ),
                                    const SizedBox(height: 24),
                                    Row(
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: () => context.push('/members/edit/${member.id}'),
                                          icon: const Icon(Icons.edit, size: 16),
                                          label: Text('Edit Member'.tr(context)),
                                          style: ElevatedButton.styleFrom(
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
                                    const Text('Account Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 16),
                                    _buildInfoRow(Icons.email_outlined, 'Email Address', member.email),
                                    const SizedBox(height: 12),
                                    _buildInfoRow(Icons.card_membership_outlined, 'Package ID', member.packageId ?? 'Lifetime'),
                                    const SizedBox(height: 12),
                                    _buildInfoRow(Icons.event_busy_outlined, 'Expiry Date', member.expiryDate?.toString().split(' ')[0] ?? 'Lifetime'),
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
                                    const Text('Timeline', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 24),
                                    _buildGlanceItem('Created', member.createdAt?.toString().split(' ')[0] ?? 'Unknown', Icons.access_time_outlined),
                                    const Divider(height: 32),
                                    _buildGlanceItem('Updated', member.updatedAt?.toString().split(' ')[0] ?? 'Unknown', Icons.update_outlined),
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
