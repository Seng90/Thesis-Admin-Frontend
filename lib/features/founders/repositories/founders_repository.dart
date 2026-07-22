import 'package:dio/dio.dart';
import 'package:investrack_admin/services/api_service.dart';
import '../models/founder_model.dart';

class FoundersRepository {
  final ApiService _apiService = ApiService();

  Future<List<Founder>> getFounders() async {
    final response = await _apiService.client.get('/admin/founders');
    final List<dynamic> data = response.data;
    return data.map((json) => Founder.fromJson(json)).toList();
  }

  Future<Founder> createFounder(Map<String, dynamic> data) async {
    final response = await _apiService.client.post('/admin/founders', data: data);
    return Founder.fromJson(response.data);
  }

  Future<Founder> updateFounder(String id, Map<String, dynamic> data) async {
    final response = await _apiService.client.patch('/admin/founders/$id', data: data);
    return Founder.fromJson(response.data);
  }

  Future<void> deleteFounder(String id) async {
    await _apiService.client.delete('/admin/founders/$id');
  }

  Future<String?> uploadFounderAvatar(dynamic fileBytes, String fileName) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(fileBytes, filename: fileName),
    });
    final response = await _apiService.client.post(
      '/admin/upload/founder-avatar',
      data: formData,
    );
    return response.data['url'];
  }
}
