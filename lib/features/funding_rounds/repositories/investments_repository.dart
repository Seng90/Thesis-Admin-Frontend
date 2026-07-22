import 'package:investrack_admin/services/api_service.dart';
import '../models/investment_model.dart';

class InvestmentsRepository {
  final ApiService _apiService = ApiService();

  Future<List<Investment>> getInvestments() async {
    final response = await _apiService.client.get('/admin/investments');
    final List<dynamic> data = response.data;
    return data.map((json) => Investment.fromJson(json)).toList();
  }

  Future<Investment> getInvestment(String id) async {
    final response = await _apiService.client.get('/admin/investments/$id');
    return Investment.fromJson(response.data);
  }

  Future<List<dynamic>> getSummaries() async {
    final response = await _apiService.client.get('/admin/investments/summary');
    return response.data;
  }

  Future<List<Map<String, dynamic>>> getFundingRounds() async {
    final response = await _apiService.client.get('/admin/funding-rounds');
    final List<dynamic> data = response.data is List ? response.data : [];
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<Investment> createInvestment(Map<String, dynamic> data) async {
    final response = await _apiService.client.post('/admin/investments', data: data);
    return Investment.fromJson(response.data);
  }

  Future<Investment> updateInvestment(String id, Map<String, dynamic> data) async {
    final response = await _apiService.client.patch('/admin/investments/$id', data: data);
    return Investment.fromJson(response.data);
  }

  Future<void> deleteInvestment(String id) async {
    await _apiService.client.delete('/admin/investments/$id');
  }

  Future<Map<String, dynamic>> createFundingRound(Map<String, dynamic> data) async {
    final response = await _apiService.client.post('/admin/funding-rounds', data: data);
    return response.data;
  }

  Future<void> deleteFundingRound(String id) async {
    await _apiService.client.delete('/admin/funding-rounds/$id');
  }
}
