import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:investrack_admin/features/admins/controllers/roles_controller.dart';
import 'package:investrack_admin/features/admins/models/role_model.dart';

class RolesPermissionsView extends StatefulWidget {
  const RolesPermissionsView({super.key});

  @override
  State<RolesPermissionsView> createState() => _RolesPermissionsViewState();
}

class _RolesPermissionsViewState extends State<RolesPermissionsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RolesController>().fetchRolesAndPermissions();
    });
  }

  void _showAddRoleDialog(BuildContext context) {
    final nameController = TextEditingController();
    final displayNameController = TextEditingController();
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add System Role'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Role Code Name (e.g. content_moderator)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: displayNameController,
                    decoration: const InputDecoration(
                      labelText: 'Display Name (e.g. Content Moderator)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  final rolesController = context.read<RolesController>();
                  final messenger = ScaffoldMessenger.of(context);
                  final navigator = Navigator.of(dialogContext);

                  final success = await rolesController.createRole(
                        nameController.text.trim(),
                        displayNameController.text.trim(),
                        descriptionController.text.trim(),
                      );
                  if (mounted && success) {
                    navigator.pop();
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Role created successfully')),
                    );
                  }
                }
              },
              child: const Text('Create Role'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RolesController>();

    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(controller.errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => controller.fetchRolesAndPermissions(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final roles = controller.roles;
    final permissions = controller.permissions;

    // Group permissions by resource for clean layout
    final Map<String, List<Permission>> groupedPermissions = {};
    for (var p in permissions) {
      groupedPermissions.putIfAbsent(p.resource, () => []).add(p);
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Roles & Permission Control Matrix',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Configure role-based action access across all system modules',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddRoleDialog(context),
                icon: const Icon(Icons.add_moderator),
                label: const Text('Add New Role'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minWidth: constraints.maxWidth),
                          child: DataTable(
                      headingRowColor: WidgetStateProperty.all(
                        Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                      ),
                      columns: [
                        const DataColumn(
                          label: Text(
                            'Module / Action Permission',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        ...roles.map(
                          (role) => DataColumn(
                            label: Row(
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      role.displayName,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '(${role.name})',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                if (!role.isSystem)
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('Delete Role'),
                                          content: Text('Are you sure you want to delete "${role.displayName}"?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(ctx, false),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.pop(ctx, true),
                                              child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        controller.deleteRole(role.id);
                                      }
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      rows: [
                        for (var entry in groupedPermissions.entries) ...[
                          // Header row for module resource
                          DataRow(
                            color: WidgetStateProperty.all(
                              Colors.grey.withOpacity(0.1),
                            ),
                            cells: [
                              DataCell(
                                Text(
                                  'MODULE: ${entry.key.toUpperCase()}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                              ),
                              ...roles.map((_) => const DataCell(SizedBox.shrink())),
                            ],
                          ),
                          // Individual permission rows
                          ...entry.value.map((permission) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  Padding(
                                    padding: const EdgeInsets.only(left: 16.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${permission.action} ${permission.resource}',
                                          style: const TextStyle(fontWeight: FontWeight.w500),
                                        ),
                                        if (permission.description != null)
                                          Text(
                                            permission.description!,
                                            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                ...roles.map((role) {
                                  final hasPermission = role.permissions.any(
                                    (p) => p.id == permission.id,
                                  );

                                  return DataCell(
                                    Checkbox(
                                      value: hasPermission,
                                      onChanged: role.isSystem && role.name == 'super_admin'
                                          ? null // Super Admin permissions are permanent
                                          : (val) {
                                              if (val != null) {
                                                controller.togglePermission(role, permission, val);
                                              }
                                            },
                                    ),
                                  );
                                }),
                              ],
                            );
                          }),
                        ],
                      ],
                    ), // DataTable
                  ), // ConstrainedBox
                ); // return SingleChildScrollView
              }, // builder LayoutBuilder
            ), // LayoutBuilder
          ), // Padding
        ), // Card
      ), // SingleChildScrollView
    ), // Expanded
  ], // Column children
), // Column
); // Padding
  }
}
