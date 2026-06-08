import 'package:flutter/foundation.dart';
import 'package:investrack_admin/services/api_service.dart';

import '../models/investment_model.dart';

class InvestmentsController extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Investment> _investments = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Investment> get investments => _investments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchInvestments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.client.get('/admin/investments');
      final List<dynamic> data = response.data;
      _investments = data.map((json) => Investment.fromJson(json)).toList();
    } catch (e) {
      if (e is DioException && e.error != null) {
        _errorMessage = e.error.toString();
      } else {
        _errorMessage = 'Failed to load investments: $e';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteInvestment(String id) async {
    try {
      await _apiService.client.delete('/admin/investments/$id');
      _investments.removeWhere((i) => i.id == id);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete investment: $e';
      notifyListeners();
    }
  }
}
