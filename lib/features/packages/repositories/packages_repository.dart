import 'package:investrack_admin/services/api_service.dart';
import '../models/package_model.dart';

class PackagesRepository {
  final ApiService _apiService = ApiService();

  Future<List<Package>> getPackages() async {
    final response = await _apiService.client.get('/admin/packages');
    final List<dynamic> data = response.data;
    return data.map((json) => Package.fromJson(json)).toList();
  }

  Future<Package> createPackage(Map<String, dynamic> data) async {
    final response = await _apiService.client.post('/admin/packages', data: data);
    return Package.fromJson(response.data);
  }

  Future<Package> updatePackage(String id, Map<String, dynamic> data) async {
    final response = await _apiService.client.patch('/admin/packages/$id', data: data);
    return Package.fromJson(response.data);
  }

  Future<void> deletePackage(String id) async {
    await _apiService.client.delete('/admin/packages/$id');
  }
}
