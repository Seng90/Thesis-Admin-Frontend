import 'package:investrack_admin/services/api_service.dart';
import '../models/investor_model.dart';

class InvestorsRepository {
  final ApiService _apiService = ApiService();

  Future<List<Investor>> getInvestors() async {
    final response = await _apiService.client.get('/admin/investors');
    final List<dynamic> data = response.data;
    return data.map((json) => Investor.fromJson(json)).toList();
  }

  Future<Investor> createInvestor(Map<String, dynamic> data) async {
    final response = await _apiService.client.post('/admin/investors', data: data);
    return Investor.fromJson(response.data);
  }

  Future<Investor> updateInvestor(String id, Map<String, dynamic> data) async {
    final response = await _apiService.client.patch('/admin/investors/$id', data: data);
    return Investor.fromJson(response.data);
  }

  Future<void> deleteInvestor(String id) async {
    await _apiService.client.delete('/admin/investors/$id');
  }
}
