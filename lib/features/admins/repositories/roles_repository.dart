import 'package:investrack_admin/services/api_service.dart';
import 'package:investrack_admin/features/admins/models/role_model.dart';

class RolesRepository {
  final ApiService _apiService = ApiService();

  Future<List<Role>> getRoles() async {
    final response = await _apiService.client.get('/admin/roles');
    final List list = response.data;
    return list.map((json) => Role.fromJson(json)).toList();
  }

  Future<List<Permission>> getPermissions() async {
    final response = await _apiService.client.get('/admin/permissions');
    final List list = response.data;
    return list.map((json) => Permission.fromJson(json)).toList();
  }

  Future<void> assignPermission(String roleId, String permissionId) async {
    await _apiService.client.post(
      '/admin/roles/$roleId/permissions',
      data: {'permission_id': permissionId},
    );
  }

  Future<void> removePermission(String roleId, String permissionId) async {
    await _apiService.client.delete(
      '/admin/roles/$roleId/permissions/$permissionId',
    );
  }

  Future<Role> createRole(String name, String displayName, String? description) async {
    final response = await _apiService.client.post(
      '/admin/roles',
      data: {
        'name': name,
        'display_name': displayName,
        'description': description,
      },
    );
    return Role.fromJson(response.data);
  }

  Future<void> deleteRole(String id) async {
    await _apiService.client.delete('/admin/roles/$id');
  }
}
