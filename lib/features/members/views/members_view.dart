import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../controllers/members_controller.dart';
import 'package:investrack_admin/utils/constants.dart';
import 'package:investrack_admin/utils/localizations.dart';

class MembersView extends StatefulWidget {
  const MembersView({super.key});

  @override
  State<MembersView> createState() => _MembersViewState();
}

class _MembersViewState extends State<MembersView> {
  final ScrollController _verticalScroll = ScrollController();
  final ScrollController _horizontalScroll = ScrollController();

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
    final strEditManage = 'Edit / Manage'.tr(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(strMembers),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
        child: Consumer<MembersController>(
          builder: (context, controller, child) {
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.errorMessage != null) {
              return Center(child: Text(controller.errorMessage!));
            }

            return LayoutBuilder(
              builder: (context, constraints) {
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
                            minWidth: MediaQuery.of(context).size.width - 64,
                          ),
                          child: Scrollbar(
                            controller: _verticalScroll,
                            thumbVisibility: true,
                            child: SingleChildScrollView(
                              controller: _verticalScroll,
                              scrollDirection: Axis.vertical,
                              child: DataTable(
                                columnSpacing: 16.0,
                                showCheckboxColumn: false,
                                columns: [
                                  DataColumn(label: Text(strMember)),
                                  DataColumn(label: Text(strStatus)),
                                  DataColumn(label: Text(strExpiry)),
                                  DataColumn(label: Text(strActions)),
                                ],
                                rows: controller.members.map((member) {
                                  final isActive = member.status == 'Active';
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(member.username, style: const TextStyle(fontWeight: FontWeight.w600)),
                                            Text(member.email, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                          ],
                                        )
                                      ),
                                      DataCell(
                                        Chip(
                                          label: Text(member.status, style: TextStyle(color: isActive ? AppColors.success : AppColors.error)),
                                          backgroundColor: isActive ? AppColors.successBg : AppColors.errorBg,
                                        ),
                                      ),
                                      DataCell(Text(member.expiryDate?.toString().split(' ')[0] ?? 'Lifetime', style: const TextStyle(color: AppColors.textSecondary))),
                                      DataCell(
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            PopupMenuButton<String>(
                                              icon: const Icon(Icons.more_horiz, color: AppColors.textMuted),
                                              onSelected: (value) {
                                                if (value == 'edit') {
                                                  context.push('/members/edit/${member.id}');
                                                } else if (value == 'block') {
                                                  controller.blockMember(member.id);
                                                }
                                              },
                                              itemBuilder: (context) => [
                                                if (isActive)
                                                  PopupMenuItem(
                                                    value: 'block',
                                                    child: Text(strBlock, style: const TextStyle(color: AppColors.error)),
                                                  ),
                                                PopupMenuItem(
                                                  value: 'edit',
                                                  child: Text(strEditManage),
                                                ),
                                              ],
                                            ),
                                          ],
                                        )
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
              }
            );
          },
        ),
      ),
    );
  }
}
