import 'package:flutter/material.dart';
import '../models/investor_model.dart';
import '../repositories/investors_repository.dart';
import 'package:investrack_admin/utils/error_handler.dart';

class InvestorsController extends ChangeNotifier {
  final InvestorsRepository _repository = InvestorsRepository();

  List<Investor> _investors = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Investor> get investors => _investors;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadInvestors() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _investors = await _repository.getInvestors();
    } catch (e) {
      _errorMessage = ErrorHandler.getErrorMessage(e, defaultMessage: 'Failed to load investors');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteInvestor(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteInvestor(id);
      _investors.removeWhere((i) => i.id == id);
      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.getErrorMessage(e, defaultMessage: 'Failed to delete investor');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addInvestor(Investor investor) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = investor.toJson()
        ..remove('id')
        ..remove('created_at');
      final created = await _repository.createInvestor(data);
      _investors.add(created);
      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.getErrorMessage(e, defaultMessage: 'Failed to add investor');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateInvestor(Investor updatedInvestor) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = updatedInvestor.toJson()
        ..remove('id')
        ..remove('created_at');
      final updated = await _repository.updateInvestor(updatedInvestor.id, data);
      final index = _investors.indexWhere((i) => i.id == updatedInvestor.id);
      if (index != -1) {
        _investors[index] = updated;
      }
      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.getErrorMessage(e, defaultMessage: 'Failed to update investor');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
