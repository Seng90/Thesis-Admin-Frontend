import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/member_log_model.dart';
import '../controllers/members_controller.dart';
import 'package:investrack_admin/utils/constants.dart';
import 'package:investrack_admin/utils/localizations.dart';
import 'package:investrack_admin/features/revisions/controllers/revisions_controller.dart';
import 'package:investrack_admin/widgets/custom_logo_widget.dart';

class MembersView extends StatefulWidget {
  const MembersView({super.key});

  @override
  State<MembersView> createState() => _MembersViewState();
}

class _MembersViewState extends State<MembersView> {
  final ScrollController _verticalScroll = ScrollController();
  final ScrollController _horizontalScroll = ScrollController();
  String _searchQuery = '';
  String _statusFilter = 'All';

  @override
  void dispose() {
    _verticalScroll.dispose();
    _horizontalScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strMembers = 'Members'.tr(context);
    final strMember = 'MEMBER'.tr(context);
    final strStatus = 'STATUS'.tr(context);
    final strExpiry = 'EXPIRY'.tr(context);
    final strActions = 'ACTIONS'.tr(context);
    final strBlock = 'Block'.tr(context);
    final strViewDetails = 'View Details'.tr(context);
    final strEditManage = 'Edit / Manage'.tr(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(strMembers),
          actions: [
            Consumer<MembersController>(
              builder: (context, controller, child) {
                return TextButton.icon(
                  onPressed: controller.isLoading
                      ? null
                      : () async {
                          final success = await controller.checkExpiry();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  success
                                      ? 'Expirations checked and synced successfully!'
                                            .tr(context)
                                      : (controller.errorMessage ??
                                            'Failed to sync expirations.'.tr(
                                              context,
                                            )),
                                ),
                                backgroundColor: success
                                    ? AppColors.success
                                    : AppColors.error,
                              ),
                            );
                          }
                        },
                  icon: const Icon(Icons.sync),
                  label: Text('Sync Expiry'.tr(context)),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                );
              },
            ),
            const SizedBox(width: 16),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: 'Members List'.tr(context)),
              Tab(text: 'Action History'.tr(context)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 32.0,
                vertical: 24.0,
              ),
              child: Consumer<MembersController>(
                builder: (context, controller, child) {
                  if (controller.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.errorMessage != null) {
                    return Center(child: Text(controller.errorMessage!));
                  }

                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search by username or email...',
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          DropdownButton<String>(
                            value: _statusFilter,
                            items: ['All', 'Active', 'Blocked', 'Inactive'].map(
                              (status) {
                                return DropdownMenuItem(
                                  value: status,
                                  child: Text(status),
                                );
                              },
                            ).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _statusFilter = value;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            var filteredList = controller.members.where((m) {
                              final matchesSearch =
                                  _searchQuery.isEmpty ||
                                  m.username.toLowerCase().contains(
                                    _searchQuery.toLowerCase(),
                                  ) ||
                                  m.email.toLowerCase().contains(
                                    _searchQuery.toLowerCase(),
                                  );
                              final matchesStatus =
                                  _statusFilter == 'All' ||
                                  m.status == _statusFilter;
                              return matchesSearch && matchesStatus;
                            }).toList();

                            if (filteredList.isEmpty) {
                              return const Center(
                                child: Text('No members match your filters.'),
                              );
                            }

                            return Card(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Scrollbar(
                                  controller: _horizontalScroll,
                                  thumbVisibility: true,
                                  child: SingleChildScrollView(
                                    controller: _horizontalScroll,
                                    scrollDirection: Axis.horizontal,
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        minHeight: constraints.maxHeight,
                                        minWidth: constraints.maxWidth,
                                      ),
                                      child: Scrollbar(
                                        controller: _verticalScroll,
                                        thumbVisibility: true,
                                        child: SingleChildScrollView(
                                          controller: _verticalScroll,
                                          scrollDirection: Axis.vertical,
                                          child: DataTable(
                                            columnSpacing: 24.0,
                                            showCheckboxColumn: false,
                                            columns: [
                                              DataColumn(
                                                label: Text(strMember),
                                              ),
                                              DataColumn(label: Text('Role')),
                                              DataColumn(
                                                label: Text(strStatus),
                                              ),
                                              DataColumn(
                                                label: Text(strExpiry),
                                              ),
                                              DataColumn(
                                                label: Text(strActions),
                                              ),
                                            ],
                                            rows: filteredList.map((member) {
                                              final isActive =
                                                  member.status == 'Active';
                                              return DataRow(
                                                cells: [
                                                  DataCell(
                                                    Row(
                                                      children: [
                                                        CustomLogoWidget(
                                                          imageUrl:
                                                              member.avatarUrl,
                                                          fallbackName:
                                                              member.username,
                                                          size: 32,
                                                        ),
                                                        const SizedBox(
                                                          width: 12,
                                                        ),
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Text(
                                                              member.username,
                                                              style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ),
                                                            Text(
                                                              member.email,
                                                              style: const TextStyle(
                                                                fontSize: 12,
                                                                color: AppColors
                                                                    .textSecondary,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  DataCell(
                                                    DropdownButtonHideUnderline(
                                                      child: DropdownButton<String>(
                                                        value:
                                                            [
                                                              'founder',
                                                              'user',
                                                              'membership',
                                                            ].contains(
                                                              member.role
                                                                  .toLowerCase(),
                                                            )
                                                            ? member.role
                                                                  .toLowerCase()
                                                            : 'user',
                                                        icon: const Icon(
                                                          Icons.arrow_drop_down,
                                                          size: 16,
                                                        ),
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 13,
                                                          color:
                                                              AppColors.primary,
                                                        ),
                                                        onChanged: (String? newValue) async {
                                                          if (newValue !=
                                                                  null &&
                                                              newValue !=
                                                                  member.role) {
                                                            final revCtrl =
                                                                Provider.of<
                                                                  RevisionsController
                                                                >(
                                                                  context,
                                                                  listen: false,
                                                                );
                                                            final success = await revCtrl
                                                                .createRevision(
                                                                  entityType:
                                                                      'Member',
                                                                  entityId:
                                                                      member.id,
                                                                  proposedChanges: {
                                                                    'role':
                                                                        newValue,
                                                                  },
                                                                );
                                                            if (context
                                                                .mounted) {
                                                              ScaffoldMessenger.of(
                                                                context,
                                                              ).showSnackBar(
                                                                SnackBar(
                                                                  content: Text(
                                                                    success
                                                                        ? 'Role change submitted for review!'.tr(
                                                                            context,
                                                                          )
                                                                        : (revCtrl.errorMessage ??
                                                                              'Failed to submit role change'.tr(
                                                                                context,
                                                                              )),
                                                                  ),
                                                                  backgroundColor:
                                                                      success
                                                                      ? AppColors
                                                                            .success
                                                                      : AppColors
                                                                            .error,
                                                                ),
                                                              );
                                                            }
                                                          }
                                                        },
                                                        items:
                                                            [
                                                              'user',
                                                              'membership',
                                                              'founder',
                                                            ].map<
                                                              DropdownMenuItem<
                                                                String
                                                              >
                                                            >((String value) {
                                                              return DropdownMenuItem<
                                                                String
                                                              >(
                                                                value: value,
                                                                child: Text(
                                                                  value
                                                                      .toUpperCase(),
                                                                ),
                                                              );
                                                            }).toList(),
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Chip(
                                                      label: Text(
                                                        member.status,
                                                        style: TextStyle(
                                                          color: isActive
                                                              ? AppColors
                                                                    .success
                                                              : AppColors.error,
                                                        ),
                                                      ),
                                                      backgroundColor: isActive
                                                          ? AppColors.successBg
                                                          : AppColors.errorBg,
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Text(
                                                      member.expiryDate
                                                              ?.toString()
                                                              .split(' ')[0] ??
                                                          'Lifetime',
                                                      style: const TextStyle(
                                                        color: AppColors
                                                            .textSecondary,
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        PopupMenuButton<String>(
                                                          icon: const Icon(
                                                            Icons.more_horiz,
                                                            color: AppColors
                                                                .textMuted,
                                                          ),
                                                          onSelected: (value) {
                                                            if (value ==
                                                                'view') {
                                                              context.push(
                                                                '/members/view/${member.id}',
                                                              );
                                                            } else if (value ==
                                                                'edit') {
                                                              context.push(
                                                                '/members/edit/${member.id}',
                                                              );
                                                            } else if (value ==
                                                                'block') {
                                                              final revCtrl =
                                                                  Provider.of<
                                                                    RevisionsController
                                                                  >(
                                                                    context,
                                                                    listen:
                                                                        false,
                                                                  );
                                                              revCtrl.createRevision(
                                                                entityType:
                                                                    'Member',
                                                                entityId:
                                                                    member.id,
                                                                proposedChanges: {
                                                                  'status':
                                                                      'Blocked',
                                                                },
                                                              );
                                                              ScaffoldMessenger.of(
                                                                context,
                                                              ).showSnackBar(
                                                                const SnackBar(
                                                                  content: Text(
                                                                    'Block request submitted for review!',
                                                                  ),
                                                                ),
                                                              );
                                                            }
                                                          },
                                                          itemBuilder: (context) => [
                                                            if (isActive)
                                                              PopupMenuItem(
                                                                value: 'block',
                                                                child: Text(
                                                                  strBlock,
                                                                  style: const TextStyle(
                                                                    color: AppColors
                                                                        .error,
                                                                  ),
                                                                ),
                                                              ),
                                                            PopupMenuItem(
                                                              value: 'view',
                                                              child: Text(
                                                                strViewDetails,
                                                              ),
                                                            ),
                                                            PopupMenuItem(
                                                              value: 'edit',
                                                              child: Text(
                                                                strEditManage,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const MemberActionHistoryTab(),
          ],
        ),
      ),
    );
  }
}

class MemberActionHistoryTab extends StatefulWidget {
  const MemberActionHistoryTab({super.key});

  @override
  State<MemberActionHistoryTab> createState() => _MemberActionHistoryTabState();
}

class _MemberActionHistoryTabState extends State<MemberActionHistoryTab> {
  String _searchQuery = '';
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MembersController>(context, listen: false).loadGlobalLogs();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Color _getActionColor(String action) {
    final act = action.toLowerCase();
    if (act.contains('block') || act.contains('delete')) {
      return AppColors.error;
    }
    if (act.contains('unblock') || act.contains('active')) {
      return AppColors.success;
    }
    if (act.contains('role')) {
      return AppColors.primary;
    }
    if (act.contains('company') || act.contains('companies')) {
      return Colors.blue;
    }
    return AppColors.textSecondary;
  }

  IconData _getActionIcon(String action) {
    final act = action.toLowerCase();
    if (act.contains('block')) {
      return Icons.block_flipped;
    }
    if (act.contains('delete')) {
      return Icons.delete_outline;
    }
    if (act.contains('unblock') || act.contains('active')) {
      return Icons.check_circle_outline;
    }
    if (act.contains('role')) {
      return Icons.admin_panel_settings_outlined;
    }
    if (act.contains('company') || act.contains('companies')) {
      return Icons.business_outlined;
    }
    return Icons.info_outline;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
      child: Consumer<MembersController>(
        builder: (context, controller, child) {
          if (controller.isLoadingLogs) {
            return const Center(child: CircularProgressIndicator());
          }

          final List<MemberLog> logs = controller.globalLogs.where((log) {
            if (_searchQuery.isEmpty) {
              return true;
            }
            final query = _searchQuery.toLowerCase();
            final actionMatch = log.action.toLowerCase().contains(query);
            final adminMatch =
                log.admin?.username.toLowerCase().contains(query) ?? false;
            final memberMatch =
                log.member?.username.toLowerCase().contains(query) ?? false;
            return actionMatch || adminMatch || memberMatch;
          }).toList();

          return Column(
            children: [
              // Search Bar
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search logs...'.tr(context),
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      controller.loadGlobalLogs();
                    },
                    tooltip: 'Refresh'.tr(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: logs.isEmpty
                    ? Center(
                        child: Text(
                          'No logs found'.tr(context),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    : Card(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Scrollbar(
                            controller: _scrollController,
                            thumbVisibility: true,
                            child: ListView.separated(
                              controller: _scrollController,
                              itemCount: logs.length,
                              separatorBuilder: (context, index) {
                                return const Divider(height: 1);
                              },
                              itemBuilder: (context, index) {
                                final log = logs[index];
                                final actionColor = _getActionColor(log.action);
                                final actionIcon = _getActionIcon(log.action);
                                final formattedDate = DateFormat(
                                  'dd/MM/yyyy HH:mm',
                                ).format(log.createdAt);

                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: actionColor.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      actionIcon,
                                      color: actionColor,
                                      size: 24,
                                    ),
                                  ),
                                  title: Text(
                                    log.action,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Wrap(
                                      spacing: 16,
                                      runSpacing: 8,
                                      children: [
                                        if (log.admin != null) ...[
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.person_outline,
                                                size: 14,
                                                color: AppColors.textMuted,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Admin: ${log.admin!.username} (${log.admin!.role})',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                        if (log.member != null) ...[
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.group_outlined,
                                                size: 14,
                                                color: AppColors.textMuted,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Target: ${log.member!.username} (${log.member!.role})',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  trailing: Text(
                                    formattedDate,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
