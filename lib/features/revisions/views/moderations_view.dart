import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:investrack_admin/utils/constants.dart';
import 'package:investrack_admin/widgets/admin_header.dart';
import 'package:investrack_admin/features/revisions/controllers/revisions_controller.dart';
import 'package:investrack_admin/features/revisions/models/revision_model.dart';
import 'package:investrack_admin/features/companies/controllers/companies_controller.dart';
import 'package:investrack_admin/features/members/controllers/members_controller.dart';
import 'package:investrack_admin/features/founders/controllers/founders_controller.dart';
import 'package:investrack_admin/features/funding_rounds/controllers/investments_controller.dart';
import 'package:investrack_admin/features/packages/controllers/packages_controller.dart';
import 'package:investrack_admin/features/fundraising_posts/controllers/fundraising_posts_controller.dart';

class ModerationsView extends StatefulWidget {
  const ModerationsView({super.key});

  @override
  State<ModerationsView> createState() => _ModerationsViewState();
}

class _ModerationsViewState extends State<ModerationsView> {
  bool _isInit = false;
  String _selectedTab = 'All';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final controller = Provider.of<RevisionsController>(
        context,
        listen: false,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.loadPendingRevisions();
      });
      _isInit = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AdminHeader(
              title: 'Moderation Queue',
              subtitle:
                  'Review user submissions and edit suggestions before they go live',
            ),
            const SizedBox(height: 24),

            // Alert Box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.warningBg.withValues(alpha: 0.5),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.3),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.alertCircle,
                    color: AppColors.warning,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Consumer<RevisionsController>(
                    builder: (context, controller, child) {
                      return Text(
                        '${controller.pendingRevisions.length} pending submissions',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Tabs
            Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTab('All'),
                    _buildTab('Companies'),
                    _buildTab('Investors'),
                    _buildTab('Members'),
                    _buildTab('Packages'),
                    _buildTab('Founders'),
                    _buildTab('Investments'),
                    _buildTab('Fundraising Posts'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // List
            Expanded(
              child: Consumer<RevisionsController>(
                builder: (context, controller, child) {
                  if (controller.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.pendingRevisions.isEmpty) {
                    return const Center(
                      child: Text('No pending revisions in queue.'),
                    );
                  }

                  // Filter logic based on tab
                  var filteredList = controller.pendingRevisions.where((r) {
                    if (_selectedTab == 'All') return true;

                    String expectedType = r.entityType.toLowerCase();
                    if (_selectedTab == 'Companies') {
                      return expectedType == 'company';
                    }
                    if (_selectedTab == 'Fundraising Posts') {
                      return expectedType == 'fundraisingpost';
                    }

                    // Default generic plural to singular mapping
                    String tabSingular = _selectedTab
                        .substring(0, _selectedTab.length - 1)
                        .toLowerCase();
                    return expectedType == tabSingular;
                  }).toList();

                  if (filteredList.isEmpty) {
                    return Center(
                      child: Text('No pending revisions match $_selectedTab.'),
                    );
                  }

                  return ListView.separated(
                    itemCount: filteredList.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final revision = filteredList[index];
                      return _buildRevisionCard(context, controller, revision);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String title) {
    final isSelected = _selectedTab == title;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedTab = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildRevisionCard(
    BuildContext context,
    RevisionsController controller,
    Revision revision,
  ) {
    Map<String, dynamic> changes = revision.proposedChanges;

    String changeField = 'Data';
    String changeValue = 'Multiple Fields';
    if (changes.isNotEmpty) {
      changeField = changes.keys.first.toString();
      changeValue = changes.values.first.toString();
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        revision.entityType.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warningBg.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.warning.withValues(alpha: 0.2),
                        ),
                      ),
                      child: const Text(
                        'high priority',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.warning,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${changes.length} field${changes.length > 1 ? 's' : ''} changed',
                      style: const TextStyle(
                        fontSize: 10,
                        fontFamily: 'monospace',
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  revision.entityId.isEmpty
                      ? 'Create new ${revision.entityType}'
                      : 'Update ${revision.entityType} ID: ${revision.entityId}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Submitted by Admin · ${revision.createdAt?.toString().split('.')[0] ?? 'N/A'}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background.withValues(alpha: 0.5),
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Field',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              changeField,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Change',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Text(
                                  'Old Data',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontFamily: 'monospace',
                                    color: Colors.redAccent,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 4.0,
                                  ),
                                  child: Text(
                                    '→',
                                    style: TextStyle(
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ),
                                Text(
                                  changeValue.length > 20
                                      ? '${changeValue.substring(0, 20)}...'
                                      : changeValue,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.success,
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
              ],
            ),
          ),
          const SizedBox(width: 16),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Proposed Changes Details'),
                      content: ConstrainedBox(
                        constraints: const BoxConstraints(minWidth: 400),
                        child: SingleChildScrollView(
                          child: Text(
                            const JsonEncoder.withIndent('  ').convert(changes),
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(LucideIcons.eye, size: 14),
                label: const Text('Diff', style: TextStyle(fontSize: 13)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              OutlinedButton.icon(
                onPressed: () async {
                  final success = await controller.rejectRevision(revision.id);
                  if (context.mounted) {
                    if (success) {
                      _reloadRelatedController(context, revision.entityType);
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? 'Revision rejected.'
                              : (controller.errorMessage ??
                                    'Failed to reject revision.'),
                        ),
                        backgroundColor: success
                            ? AppColors.warning
                            : AppColors.error,
                      ),
                    );
                  }
                },
                icon: const Icon(LucideIcons.x, size: 14, color: Colors.red),
                label: const Text(
                  'Reject',
                  style: TextStyle(fontSize: 13, color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  side: BorderSide(color: Colors.red.withValues(alpha: 0.3)),
                ),
              ),
              const SizedBox(width: 6),
              ElevatedButton.icon(
                onPressed: () async {
                  final success = await controller.approveRevision(revision.id);
                  if (context.mounted) {
                    if (success) {
                      _reloadRelatedController(context, revision.entityType);
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? 'Revision approved and published!'
                              : (controller.errorMessage ??
                                    'Failed to approve revision.'),
                        ),
                        backgroundColor: success
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    );
                  }
                },
                icon: const Icon(LucideIcons.check, size: 14),
                label: const Text('Approve', style: TextStyle(fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _reloadRelatedController(BuildContext context, String entityType) {
    switch (entityType.toLowerCase()) {
      case 'company':
        context.read<CompaniesController>().loadCompanies();
        break;
      case 'member':
        context.read<MembersController>().loadMembers();
        break;
      case 'founder':
        context.read<FoundersController>().fetchFounders();
        break;
      case 'investment':
      case 'fundinground':
        context.read<InvestmentsController>().fetchInvestments();
        break;
      case 'package':
        context.read<PackagesController>().loadPackages();
        break;
      case 'fundraisingpost':
      case 'fundraising_post':
        context.read<FundraisingPostsController>().loadPosts();
        break;
    }
  }
}
