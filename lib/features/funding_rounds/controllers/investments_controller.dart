import 'package:flutter/foundation.dart';
import 'package:investrack_admin/services/api_service.dart';

import '../models/investment_model.dart';
import '../models/investment_summary_model.dart';

class InvestmentsController extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Investment> _investments = [];
  List<InvestmentSummary> _summaries = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Investment> get investments => _investments;
  List<InvestmentSummary> get summaries => _summaries;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetch flat list of all investments (used by edit/detail views)
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

  /// Fetch grouped/summarized investments (used by the main list view)
  Future<void> fetchSummaries() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.client.get(
        '/admin/investments/summary',
      );
      final List<dynamic> data = response.data;
      _summaries = data
          .map((json) => InvestmentSummary.fromJson(json))
          .toList();
    } catch (e) {
      if (e is DioException && e.error != null) {
        _errorMessage = e.error.toString();
      } else {
        _errorMessage = 'Failed to load investment summaries: $e';
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
      // Also remove from summaries
      for (final summary in _summaries) {
        summary.investments.removeWhere((i) => i.id == id);
      }
      _summaries.removeWhere((s) => s.investments.isEmpty);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete investment: $e';
      notifyListeners();
    }
  }
}
