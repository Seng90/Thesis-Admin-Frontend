import 'package:investrack_admin/services/api_service.dart';

class DashboardRepository {
  final ApiService _apiService = ApiService();

  Future<dynamic> getSummary() async {
    final response = await _apiService.client.get('/admin/dashboard/summary');
    return response.data;
  }

  Future<dynamic> getSectors() async {
    final response = await _apiService.client.get('/admin/dashboard/companies-by-sector');
    return response.data;
  }

  Future<dynamic> getFundingHistory(String period) async {
    final response = await _apiService.client.get(
      '/admin/dashboard/funding-history',
      queryParameters: {'period': period},
    );
    return response.data;
  }

  Future<dynamic> getRecentCompanies() async {
    final response = await _apiService.client.get('/admin/dashboard/recent-companies');
    return response.data;
  }

  Future<dynamic> getTopStartups() async {
    final response = await _apiService.client.get('/admin/dashboard/top-startups');
    return response.data;
  }

  Future<dynamic> getPopularPackages() async {
    final response = await _apiService.client.get('/admin/dashboard/popular-packages');
    return response.data;
  }
}
