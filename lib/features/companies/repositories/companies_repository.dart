import 'package:dio/dio.dart';
import 'package:investrack_admin/services/api_service.dart';
import '../models/company_model.dart';

class CompaniesRepository {
  final ApiService _apiService = ApiService();

  Future<List<Company>> getCompanies() async {
    final response = await _apiService.client.get('/admin/companies');
    final List<dynamic> data = response.data;
    return data.map((json) => Company.fromJson(json)).toList();
  }

  Future<Company> createCompany(Map<String, dynamic> data) async {
    final response = await _apiService.client.post('/admin/companies', data: data);
    return Company.fromJson(response.data);
  }

  Future<Company> updateCompany(String id, Map<String, dynamic> data) async {
    final response = await _apiService.client.patch('/admin/companies/$id', data: data);
    return Company.fromJson(response.data);
  }

  Future<void> deleteCompany(String id) async {
    await _apiService.client.delete('/admin/companies/$id');
  }

  Future<String?> uploadCompanyLogo(dynamic fileBytes, String fileName) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(fileBytes, filename: fileName),
    });
    final response = await _apiService.client.post(
      '/admin/upload/company-logo',
      data: formData,
    );
    return response.data['url'];
  }
}
