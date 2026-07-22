import 'package:flutter/material.dart';
import 'package:investrack_admin/features/admins/models/role_model.dart';
import 'package:investrack_admin/features/admins/repositories/roles_repository.dart';

class RolesController extends ChangeNotifier {
  final RolesRepository _repository = RolesRepository();

  List<Role> _roles = [];
  List<Permission> _permissions = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Role> get roles => _roles;
  List<Permission> get permissions => _permissions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchRolesAndPermissions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetchedRoles = await _repository.getRoles();
      final fetchedPermissions = await _repository.getPermissions();
      _roles = fetchedRoles;
      _permissions = fetchedPermissions;
    } catch (e) {
      _errorMessage = 'Failed to load roles and permissions: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> togglePermission(Role role, Permission permission, bool enable) async {
    try {
      if (enable) {
        await _repository.assignPermission(role.id, permission.id);
      } else {
        await _repository.removePermission(role.id, permission.id);
      }
      await fetchRolesAndPermissions();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update permission: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> createRole(String name, String displayName, String? description) async {
    try {
      await _repository.createRole(name, displayName, description);
      await fetchRolesAndPermissions();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create role: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteRole(String roleId) async {
    try {
      await _repository.deleteRole(roleId);
      await fetchRolesAndPermissions();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete role: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
}
