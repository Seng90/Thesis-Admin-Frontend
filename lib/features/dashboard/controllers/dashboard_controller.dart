import 'package:flutter/material.dart';
import '../models/dashboard_model.dart';
import '../repositories/dashboard_repository.dart';
import 'package:investrack_admin/utils/error_handler.dart';

class DashboardController extends ChangeNotifier {
  final DashboardRepository _repository = DashboardRepository();

  DashboardSummary? summary;
  List<SectorStat> sectors = [];
  List<FundingHistoryItem> fundingHistory = [];
  List<RecentCompany> recentCompanies = [];
  List<TopStartup> topStartups = [];
  List<PopularPackage> popularPackages = [];

  bool isLoadingSummary = false;
  bool isLoadingSectors = false;
  bool isLoadingFunding = false;
  bool isLoadingRecent = false;
  bool isLoadingTopStartups = false;
  bool isLoadingPopularPackages = false;

  String? errorMessage;
  String currentFundingPeriod = '1M';

  DashboardController() {
    // Data is now loaded lazily by the View using load-on-demand
  }

  Future<void> loadAll() async {
    errorMessage = null;
    notifyListeners();

    await Future.wait([
      loadSummary(),
      loadSectors(),
      loadFundingHistory(currentFundingPeriod),
      loadRecentCompanies(),
      loadTopStartups(),
      loadPopularPackages(),
    ]);
  }

  Future<void> loadSummary() async {
    isLoadingSummary = true;
    notifyListeners();

    try {
      final data = await _repository.getSummary();
      summary = DashboardSummary.fromJson(data);
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
      final data = await _repository.getSectors();
      sectors = data.map<SectorStat>((json) => SectorStat.fromJson(json)).toList();
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
      final data = await _repository.getFundingHistory(period);
      fundingHistory = data
          .map<FundingHistoryItem>((json) => FundingHistoryItem.fromJson(json))
          .toList();
    } catch (e) {
      _handleError(e);
    } finally {
      isLoadingFunding = false;
      notifyListeners();
    }
  }

  Future<void> loadRecentCompanies() async {
    isLoadingRecent = true;
    notifyListeners();

    try {
      final data = await _repository.getRecentCompanies();
      recentCompanies = data
          .map<RecentCompany>((json) => RecentCompany.fromJson(json))
          .toList();
    } catch (e) {
      _handleError(e);
    } finally {
      isLoadingRecent = false;
      notifyListeners();
    }
  }

  Future<void> loadTopStartups() async {
    isLoadingTopStartups = true;
    notifyListeners();

    try {
      final data = await _repository.getTopStartups();
      topStartups = data.map<TopStartup>((json) => TopStartup.fromJson(json)).toList();
    } catch (e) {
      _handleError(e);
    } finally {
      isLoadingTopStartups = false;
      notifyListeners();
    }
  }

  Future<void> loadPopularPackages() async {
    isLoadingPopularPackages = true;
    notifyListeners();

    try {
      final data = await _repository.getPopularPackages();
      popularPackages = data
          .map<PopularPackage>((json) => PopularPackage.fromJson(json))
          .toList();
    } catch (e) {
      _handleError(e);
    } finally {
      isLoadingPopularPackages = false;
      notifyListeners();
    }
  }

  void _handleError(dynamic e) {
    errorMessage = ErrorHandler.getErrorMessage(e, defaultMessage: 'Dashboard API Error');
  }
}
