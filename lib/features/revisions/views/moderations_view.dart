import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:investrack_admin/utils/constants.dart';
import 'package:investrack_admin/widgets/admin_header.dart';
import 'package:investrack_admin/features/revisions/controllers/revisions_controller.dart';
import 'package:investrack_admin/features/revisions/models/revision_model.dart';
import 'package:investrack_admin/features/investors/controllers/investors_controller.dart';
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
  String _selectedTab = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<RevisionsController>(context, listen: false);
      if (controller.pendingRevisions.isEmpty && !controller.isLoading) {
        controller.loadPendingRevisions();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AdminHeader(
              title: 'Moderation Queue',
              subtitle: 'Review user submissions and edit suggestions before they go live',
              action: OutlinedButton.icon(
                onPressed: () {
                  context.read<RevisionsController>().loadPendingRevisions();
                },
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Refresh'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
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

                  if (controller.errorMessage != null) {
                    return Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                              color: AppColors.error,
                            ),
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Text(
                                controller.errorMessage!,
                                style: const TextStyle(color: AppColors.textSecondary),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => controller.loadPendingRevisions(),
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
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
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
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
                    if (revision.submitterType == 'member')
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.successBg.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.success.withValues(alpha: 0.2),
                          ),
                        ),
                        child: const Text(
                          'member request',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.success,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
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
                  revision.submitterType == 'member'
                      ? 'Requested by ${revision.requestor?['username'] ?? 'Founder'} · ${(revision.createdAt?.toString() ?? 'N/A').split('.')[0]}'
                      : 'Submitted by Admin · ${(revision.createdAt?.toString() ?? 'N/A').split('.')[0]}',
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
                                Expanded(
                                  child: Text(
                                    changeValue.length > 20
                                        ? '${changeValue.substring(0, 20)}...'
                                        : changeValue,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.success,
                                    ),
                                    overflow: TextOverflow.ellipsis,
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
                      title: const Text('Proposed Changes Details', style: TextStyle(fontWeight: FontWeight.bold)),
                      contentPadding: EdgeInsets.zero,
                      content: SizedBox(
                        width: 600,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.8,
                          ),
                          child: _buildDiffView(changes, revision.originalData),
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
              revision.submitterType == 'member'
                  ? ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          await _showPartialApprovalDialog(
                              context, controller, revision);
                        } catch (e) {
                          // Handle any unexpected errors when opening the dialog
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error opening review dialog: $e'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(LucideIcons.clipboardCheck, size: 14),
                      label: const Text('Review Request',
                          style: TextStyle(fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () async {
                            final success =
                                await controller.rejectRevision(revision.id);
                            if (context.mounted) {
                              if (success) {
                                _reloadRelatedController(
                                    context, revision.entityType);
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
                          icon: const Icon(LucideIcons.x,
                              size: 14, color: Colors.red),
                          label: const Text(
                            'Reject',
                            style: TextStyle(fontSize: 13, color: Colors.red),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            side: BorderSide(
                                color: Colors.red.withValues(alpha: 0.3)),
                          ),
                        ),
                        const SizedBox(width: 6),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final success =
                                await controller.approveRevision(revision.id);
                            if (context.mounted) {
                              if (success) {
                                _reloadRelatedController(
                                    context, revision.entityType);
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
                          label: const Text('Approve',
                              style: TextStyle(fontSize: 13)),
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
        ],
      ),
    );
  }

  Future<void> _showPartialApprovalDialog(
    BuildContext context,
    RevisionsController controller,
    Revision revision,
  ) async {
    // 🔍 DEBUG: Log when dialog is requested
    print('🟢 DEBUG: Opening approval dialog for revision ${revision.id}');
    print('   proposedChanges keys: ${revision.proposedChanges.keys.toList()}');
    print('   proposedChanges length: ${revision.proposedChanges.length}');

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        print('🟢 DEBUG: Building dialog widget...');
        return _PartialApprovalDialog(
          revision: revision,
          controller: controller,
        );
      },
    );

    if (context.mounted && result != null) {
      _reloadRelatedController(context, revision.entityType);
      String msg = '';
      if (result == 'rejected_all') {
        msg = 'Revision rejected entirely.';
      } else if (result == 'approved_all') {
        msg = 'Revision approved and published entirely!';
      } else if (result == 'partial_approved') {
        msg = 'Revision partially approved!';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _reloadRelatedController(BuildContext context, String entityType) {
    switch (entityType.toLowerCase()) {
      case 'company':
        context.read<CompaniesController>().loadCompanies();
        break;
      case 'investor':
        context.read<InvestorsController>().loadInvestors();
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

  Widget _buildDiffView(Map<String, dynamic> changes, Map<String, dynamic>? originalData) {
    if (changes.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text('No changes proposed.', style: TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(changes.length, (index) {
          final key = changes.keys.elementAt(index);
          final newValue = changes[key];
          final oldValue = originalData?[key];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      key.replaceAll('_', ' ').toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (originalData != null && oldValue != newValue)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Original Data', style: TextStyle(fontSize: 10, color: AppColors.error, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.errorBg.withValues(alpha: 0.3),
                                    border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Opacity(
                                    opacity: 0.7,
                                    child: _buildDiffValue(oldValue, isOld: true),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 24),
                            child: Icon(LucideIcons.arrowRight, size: 16, color: AppColors.textMuted),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Proposed Change', style: TextStyle(fontSize: 10, color: AppColors.success, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.successBg.withValues(alpha: 0.3),
                                    border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: _buildDiffValue(newValue),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    else
                      _buildDiffValue(newValue),
                  ],
                ),
              ),
              if (index < changes.length - 1) const Divider(height: 1),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildDiffValue(dynamic value, {bool isOld = false}) {
    if (value == null) {
      return const Text('null', style: TextStyle(color: AppColors.textMuted, fontStyle: FontStyle.italic));
    }

    if (value is bool) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: value ? AppColors.successBg : AppColors.errorBg,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          value.toString().toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: value ? AppColors.success : AppColors.error,
          ),
        ),
      );
    }

    if (value is List) {
      if (value.isEmpty) {
        return const Text('Empty List', style: TextStyle(color: AppColors.textMuted, fontStyle: FontStyle.italic));
      }
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: value.map((item) {
          return Chip(
            label: Text(item.toString(), style: const TextStyle(fontSize: 13)),
            backgroundColor: AppColors.primaryLight,
            side: BorderSide.none,
            padding: EdgeInsets.zero,
          );
        }).toList(),
      );
    }

    String stringValue = value.toString();

    // Check if URL
    if (stringValue.startsWith('http://') || stringValue.startsWith('https://')) {
      bool isImage = stringValue.endsWith('.png') || stringValue.endsWith('.jpg') || stringValue.endsWith('.jpeg') || stringValue.endsWith('.gif') || stringValue.contains('image');
      
      if (isImage) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(
              stringValue,
              style: const TextStyle(color: AppColors.primary, decoration: TextDecoration.underline, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(stringValue),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        );
      }

      return SelectableText(
        stringValue,
        style: const TextStyle(color: AppColors.primary, decoration: TextDecoration.underline, fontSize: 14),
      );
    }

    if (stringValue.length > 100 || stringValue.contains('\n')) {
      return SelectableText(
        stringValue,
        style: TextStyle(
          fontSize: 13,
          height: 1.5,
          color: isOld ? AppColors.textSecondary : AppColors.textPrimary,
          decoration: isOld ? TextDecoration.lineThrough : null,
        ),
      );
    }

    return SelectableText(
      stringValue,
      style: TextStyle(
        fontSize: 14,
        color: isOld ? AppColors.textSecondary : AppColors.textPrimary,
        fontWeight: FontWeight.w500,
        decoration: isOld ? TextDecoration.lineThrough : null,
      ),
    );
  }
}

class _PartialApprovalDialog extends StatefulWidget {
  final Revision revision;
  final RevisionsController controller;

  const _PartialApprovalDialog({
    required this.revision,
    required this.controller,
  });

  @override
  State<_PartialApprovalDialog> createState() => _PartialApprovalDialogState();
}

class _PartialApprovalDialogState extends State<_PartialApprovalDialog> {
  late Map<String, bool> _fieldApprovals;
  late Map<String, TextEditingController> _reasonControllers;
  late TextEditingController _adminNoteController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    print('🔵 DEBUG: initState started');

    _fieldApprovals = {};
    _reasonControllers = {};
    _adminNoteController = TextEditingController();

    print('🔵 DEBUG: Iterating over proposedChanges...');
    widget.revision.proposedChanges.forEach((key, value) {
      print('   Processing key: $key, value type: ${value.runtimeType}');
      _fieldApprovals[key] = true; // default to approved
      _reasonControllers[key] = TextEditingController();
    });

    print('🔵 DEBUG: initState completed');
  }

  @override
  void dispose() {
    _reasonControllers.forEach((_, c) {
      c.dispose();
    });
    _adminNoteController.dispose();
    super.dispose();
  }

  String _formatValue(dynamic val) {
    print('🟡 DEBUG: _formatValue ENTRY - type: ${val.runtimeType}');

    if (val == null) {
      print('🟡 DEBUG: val is null, returning N/A');
      return 'N/A';
    }

    // Handle primitives directly
    if (val is String || val is num || val is bool) {
      final result = val.toString();
      print('🟡 DEBUG: primitive type, returning: "$result"');
      return result;
    }

    // For Maps and Lists, use a safe converter with depth limit
    if (val is Map || val is List) {
      try {
        print('   Attempting safe conversion...');
        final result = _safeJsonConvert(val, maxDepth: 10);
        print('   safe conversion SUCCESS');
        return result;
      } catch (e) {
        print('   safe conversion FAILED: $e');
        // Fallback to simple string representation
        return '[${val.runtimeType}] (too complex to display)';
      }
    }

    print('🟡 DEBUG: fallback to toString()');
    return val.toString();
  }

  /// Safely converts complex objects to JSON string with depth limit to prevent infinite loops
  String _safeJsonConvert(dynamic value, {int maxDepth = 10, int currentDepth = 0}) {
    if (currentDepth >= maxDepth) {
      return '[max depth reached]';
    }

    if (value == null) return 'null';
    if (value is String) return '"$value"';
    if (value is num || value is bool) return value.toString();

    if (value is List) {
      if (value.isEmpty) return '[]';
      final items = value.take(5).map((e) => _safeJsonConvert(e, maxDepth: maxDepth, currentDepth: currentDepth + 1)).join(', ');
      final remaining = value.length > 5 ? ' ... (+${value.length - 5} more)' : '';
      return '[$items$remaining]';
    }

    if (value is Map) {
      if (value.isEmpty) return '{}';
      final entries = value.entries.take(5).map((e) => '${e.key}: ${_safeJsonConvert(e.value, maxDepth: maxDepth, currentDepth: currentDepth + 1)}').join(', ');
      final remaining = value.length > 5 ? ' ... (+${value.length - 5} more)' : '';
      return '{$entries$remaining}';
    }

    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(LucideIcons.clipboardCheck, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Review Request from: ${widget.revision.requestor?['username'] ?? 'Founder'}',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 600,
        height: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Entity: ${widget.revision.entityType} (ID: ${widget.revision.entityId})',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 12),
            const Text(
              'Review each field and choose to Approve or Reject:',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: widget.revision.proposedChanges.keys.map((field) {
                  final proposedVal = widget.revision.proposedChanges[field];
                  final isApproved = _fieldApprovals[field] ?? true;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(8),
                      color: AppColors.background.withValues(alpha: 0.2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              field,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Row(
                              children: [
                                ChoiceChip(
                                  label: const Text('Approve'),
                                  selected: isApproved,
                                  onSelected: (selected) {
                                    setState(() {
                                      _fieldApprovals[field] = true;
                                    });
                                  },
                                  selectedColor: AppColors.success.withValues(alpha: 0.2),
                                  labelStyle: TextStyle(
                                    color: isApproved
                                        ? AppColors.success
                                        : AppColors.textSecondary,
                                    fontWeight:
                                        isApproved ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ChoiceChip(
                                  label: const Text('Reject'),
                                  selected: !isApproved,
                                  onSelected: (selected) {
                                    setState(() {
                                      _fieldApprovals[field] = false;
                                    });
                                  },
                                  selectedColor: Colors.red.withValues(alpha: 0.2),
                                  labelStyle: TextStyle(
                                    color: !isApproved
                                        ? Colors.red
                                        : AppColors.textSecondary,
                                    fontWeight:
                                        !isApproved ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Proposed Value:',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _formatValue(proposedVal),
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        ),
                        !isApproved
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: _reasonControllers[field],
                                    decoration: const InputDecoration(
                                      labelText: 'Reason for rejection',
                                      hintText: 'e.g. Invalid website URL, typos, etc.',
                                      labelStyle: TextStyle(fontSize: 12),
                                      hintStyle: TextStyle(fontSize: 12),
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 8),
                                      border: OutlineInputBorder(),
                                    ),
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _adminNoteController,
              decoration: const InputDecoration(
                labelText: 'Admin Note / Feedback to Founder',
                hintText: 'Add general notes about this moderation action...',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        const Spacer(),
        OutlinedButton(
          onPressed: _isSubmitting
              ? null
              : () async {
                  setState(() => _isSubmitting = true);
                  try {
                    final success =
                        await widget.controller.rejectRevision(widget.revision.id);
                    if (context.mounted) {
                      Navigator.pop(context, success ? 'rejected_all' : null);
                    }
                  } catch (e) {
                    // Error is handled by controller and stored in errorMessage
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              widget.controller.errorMessage ?? 'Failed to reject revision'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  } finally {
                    if (mounted) setState(() => _isSubmitting = false);
                  }
                },
          style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Reject All'),
        ),
        const SizedBox(width: 8),
        OutlinedButton(
          onPressed: _isSubmitting
              ? null
              : () async {
                  setState(() => _isSubmitting = true);
                  try {
                    final success =
                        await widget.controller.approveRevision(widget.revision.id);
                    if (context.mounted) {
                      Navigator.pop(context, success ? 'approved_all' : null);
                    }
                  } catch (e) {
                    // Error is handled by controller and stored in errorMessage
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              widget.controller.errorMessage ?? 'Failed to approve revision'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  } finally {
                    if (mounted) setState(() => _isSubmitting = false);
                  }
                },
          style: OutlinedButton.styleFrom(foregroundColor: AppColors.success),
          child: const Text('Approve All'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: _isSubmitting
              ? null
              : () async {
                  setState(() => _isSubmitting = true);

                  final fieldDecisions = <String, dynamic>{};
                  _fieldApprovals.forEach((field, approved) {
                    final decision = <String, dynamic>{
                      'status': approved ? 'approved' : 'rejected',
                    };
                    if (!approved) {
                      decision['reason'] = _reasonControllers[field]?.text ?? '';
                    }
                    fieldDecisions[field] = decision;
                  });

                  final adminNote = _adminNoteController.text.trim();

                  try {
                    final success = await widget.controller.partialApproveRevision(
                      widget.revision.id,
                      fieldDecisions,
                      adminNote.isNotEmpty ? adminNote : null,
                    );

                    if (context.mounted) {
                      Navigator.pop(context, success ? 'partial_approved' : null);
                    }
                  } catch (e) {
                    // Error is handled by controller and stored in errorMessage
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              widget.controller.errorMessage ?? 'Failed to partially approve revision'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  } finally {
                    if (mounted) setState(() => _isSubmitting = false);
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : const Text('Partial Approve'),
        ),
      ],
    );
  }
}
