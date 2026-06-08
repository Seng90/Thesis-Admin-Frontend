import 'package:flutter/foundation.dart';
import 'package:investrack_admin/services/api_service.dart';
import '../models/dashboard_model.dart';

class DashboardController extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  DashboardSummary? summary;
  List<SectorStat> sectors = [];
  List<FundingHistoryItem> fundingHistory = [];
  
  bool isLoadingSummary = false;
  bool isLoadingSectors = false;
  bool isLoadingFunding = false;
  
  String? errorMessage;
  String currentFundingPeriod = '1M';

  DashboardController() {
    loadAll();
  }

  Future<void> loadAll() async {
    errorMessage = null;
    notifyListeners();
    
    await Future.wait([
      loadSummary(),
      loadSectors(),
      loadFundingHistory(currentFundingPeriod),
    ]);
  }

  Future<void> loadSummary() async {
    isLoadingSummary = true;
    notifyListeners();

    try {
      final response = await _apiService.client.get('/admin/dashboard/summary');
      summary = DashboardSummary.fromJson(response.data);
    } catch (e) {
      _handleError(e);
    } finally {
      isLoadingSummary = false;
      notifyListeners();
    }
  }

  Future<void> loadSectors() async {
    isLoadingSectors = true;
    notifyListeners();

    try {
      final response = await _apiService.client.get('/admin/dashboard/companies-by-sector');
      final List<dynamic> data = response.data;
      sectors = data.map((json) => SectorStat.fromJson(json)).toList();
    } catch (e) {
      _handleError(e);
    } finally {
      isLoadingSectors = false;
      notifyListeners();
    }
  }

  Future<void> loadFundingHistory(String period) async {
    currentFundingPeriod = period;
    isLoadingFunding = true;
    notifyListeners();

    try {
      final response = await _apiService.client.get(
        '/admin/dashboard/funding-history',
        queryParameters: {'period': period},
      );
      final List<dynamic> data = response.data;
      fundingHistory = data.map((json) => FundingHistoryItem.fromJson(json)).toList();
    } catch (e) {
      _handleError(e);
    } finally {
      isLoadingFunding = false;
      notifyListeners();
    }
  }

  void _handleError(dynamic e) {
    if (e is DioException && e.error != null) {
      errorMessage = e.error.toString();
    } else {
      errorMessage = 'Dashboard API Error: $e';
    }
  }
}
