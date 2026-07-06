import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:investrack_admin/features/auth/controllers/auth_controller.dart';

class PermissionHelper {
  static bool hasPermission(BuildContext context, String permission) {
    final user = Provider.of<AuthController>(context, listen: false).currentUser;
    return user?.permissions.contains(permission) ?? false;
  }

  static bool hasRole(BuildContext context, String role) {
    final user = Provider.of<AuthController>(context, listen: false).currentUser;
    return user?.roles.contains(role) ?? false;
  }

  static bool hasAnyPermission(BuildContext context, List<String> permissions) {
    final user = Provider.of<AuthController>(context, listen: false).currentUser;
    if (user == null) return false;
    return permissions.any((p) => user.permissions.contains(p));
  }
}
