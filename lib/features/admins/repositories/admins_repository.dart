import 'package:dio/dio.dart';
import 'package:investrack_admin/services/api_service.dart';

class AdminsRepository {
  final ApiService _apiService = ApiService();

  Future<List<dynamic>> getAdmins() async {
    final response = await _apiService.client.get('/admin/admins');
    return response.data;
  }

  Future<dynamic> getAdmin(String id) async {
    final response = await _apiService.client.get('/admin/admins/$id');
    return response.data;
  }

  Future<dynamic> createAdmin(Map<String, dynamic> data) async {
    final response = await _apiService.client.post('/admin/admins', data: data);
    return response.data;
  }

  Future<dynamic> updateAdmin(String id, Map<String, dynamic> data) async {
    final response = await _apiService.client.patch('/admin/admins/$id', data: data);
    return response.data;
  }

  Future<dynamic> deleteAdmin(String id) async {
    final response = await _apiService.client.delete('/admin/admins/$id');
    return response.data;
  }
}
