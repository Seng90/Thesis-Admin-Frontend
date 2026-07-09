import 'package:flutter/material.dart';
import '../models/investment_model.dart';
import '../models/investment_summary_model.dart';
import '../repositories/investments_repository.dart';
import 'package:investrack_admin/utils/error_handler.dart';

class InvestmentsController extends ChangeNotifier {
  final InvestmentsRepository _repository = InvestmentsRepository();

  List<Investment> _investments = [];
  List<InvestmentSummary> _summaries = [];
  List<Map<String, dynamic>> _fundingRounds = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Investment> get investments => _investments;
  List<InvestmentSummary> get summaries => _summaries;
  List<Map<String, dynamic>> get fundingRounds => _fundingRounds;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetch flat list of all investments
  Future<void> fetchInvestments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _investments = await _repository.getInvestments();
    } catch (e) {
      _errorMessage = ErrorHandler.getErrorMessage(e, defaultMessage: 'Failed to load investments');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch grouped/summarized investments
  Future<void> fetchSummaries() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _repository.getSummaries();
      _summaries = data.map((json) => InvestmentSummary.fromJson(json)).toList();
    } catch (e) {
      _errorMessage = ErrorHandler.getErrorMessage(e, defaultMessage: 'Failed to load investment summaries');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch available funding rounds
  Future<void> fetchFundingRounds() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _fundingRounds = await _repository.getFundingRounds();
    } catch (e) {
      _errorMessage = ErrorHandler.getErrorMessage(e, defaultMessage: 'Failed to load funding rounds');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch single investment details
  Future<Investment?> fetchInvestmentDetail(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      return await _repository.getInvestment(id);
    } catch (e) {
      _errorMessage = ErrorHandler.getErrorMessage(e, defaultMessage: 'Failed to load investment details');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete an investment and update local lists
  Future<bool> deleteInvestment(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteInvestment(id);
      _investments.removeWhere((i) => i.id == id);
      // Update summaries
      for (final summary in _summaries) {
        summary.investments.removeWhere((i) => i.id == id);
      }
      _summaries.removeWhere((s) => s.investments.isEmpty);
      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.getErrorMessage(e, defaultMessage: 'Failed to delete investment');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
