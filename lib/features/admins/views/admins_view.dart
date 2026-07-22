import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../controllers/admins_controller.dart';
import 'package:investrack_admin/utils/constants.dart';
import 'package:investrack_admin/utils/localizations.dart';
import '../../auth/controllers/auth_controller.dart';

class AdminsView extends StatefulWidget {
  const AdminsView({super.key});

  @override
  State<AdminsView> createState() => _AdminsViewState();
}

class _AdminsViewState extends State<AdminsView> {
  final ScrollController _horizontalScroll = ScrollController();
  final ScrollController _verticalScroll = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminsController>().loadAdmins();
    });
  }

  @override
  void dispose() {
    _horizontalScroll.dispose();
    _verticalScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Admins'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Consumer<AdminsController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    controller.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.loadAdmins(),
                    child: Text('Retry'.tr(context)),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Admin Accounts',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => context.push('/admins/add'),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Admin'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: Card(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Scrollbar(
                        controller: _horizontalScroll,
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          controller: _horizontalScroll,
                          scrollDirection: Axis.horizontal,
                          child: Scrollbar(
                            controller: _verticalScroll,
                            thumbVisibility: true,
                            child: SingleChildScrollView(
                              controller: _verticalScroll,
                              scrollDirection: Axis.vertical,
                              child: DataTable(
                                columnSpacing: 24.0,
                                showCheckboxColumn: false,
                                columns: const [
                                  DataColumn(label: Text('Username')),
                                  DataColumn(label: Text('Email')),
                                  DataColumn(label: Text('Role')),
                                  DataColumn(label: Text('Status')),
                                  DataColumn(label: Text('Actions')),
                                ],
                                rows: controller.admins.map((admin) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(admin.username, style: const TextStyle(fontWeight: FontWeight.w600))),
                                      DataCell(Text(admin.email)),
                                      DataCell(
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: admin.role == 'super_admin' ? Colors.purple.shade50 : AppColors.primaryLight,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            admin.role,
                                            style: TextStyle(
                                              color: admin.role == 'super_admin' ? Colors.purple : AppColors.primary,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: admin.status == 'Active' ? AppColors.successBg : AppColors.errorBg,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            admin.status,
                                            style: TextStyle(
                                              color: admin.status == 'Active' ? AppColors.success : AppColors.error,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit, color: AppColors.primary),
                                              onPressed: () => context.push('/admins/edit/${admin.id}'),
                                              tooltip: 'Edit',
                                            ),
                                            if (admin.id != context.read<AuthController>().currentUser?.id)
                                              IconButton(
                                                icon: const Icon(Icons.delete, color: AppColors.error),
                                                onPressed: () => _confirmDelete(context, admin.id),
                                                tooltip: 'Delete',
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
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Admin'),
        content: const Text('Are you sure you want to delete this admin account?'),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ctx.pop();
              context.read<AdminsController>().deleteAdmin(id).then((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Admin deleted successfully')),
                );
              }).catchError((e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting admin')),
                );
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
