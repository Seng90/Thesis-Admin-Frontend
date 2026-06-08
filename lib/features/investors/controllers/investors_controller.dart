import 'package:flutter/material.dart';
import '../models/investor_model.dart';
import 'package:investrack_admin/services/api_service.dart';

class InvestorsController extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
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
      final response = await _apiService.client.get('/admin/investors');
      final List<dynamic> data = response.data;
      _investors = data.map((json) => Investor.fromJson(json)).toList();
    } catch (e) {
      if (e is DioException && e.error != null) {
        _errorMessage = e.error.toString();
      } else {
        _errorMessage = 'Failed to load investors: $e';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteInvestor(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.client.delete('/admin/investors/$id');
      _investors.removeWhere((i) => i.id == id);
    } catch (e) {
      if (e is DioException && e.error != null) {
        _errorMessage = e.error.toString();
      } else {
        _errorMessage = 'Failed to delete investor: $e';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addInvestor(Investor investor) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = investor.toJson()..remove('id')..remove('created_at');
      final response = await _apiService.client.post('/admin/investors', data: data);
      final newInvestor = Investor.fromJson(response.data);
      _investors.add(newInvestor);
    } catch (e) {
      if (e is DioException && e.error != null) {
        _errorMessage = e.error.toString();
      } else {
        _errorMessage = 'Failed to add investor: $e';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateInvestor(Investor updatedInvestor) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = updatedInvestor.toJson()..remove('id')..remove('created_at');
      await _apiService.client.patch('/admin/investors/${updatedInvestor.id}', data: data);
      final index = _investors.indexWhere((i) => i.id == updatedInvestor.id);
      if (index != -1) {
        _investors[index] = updatedInvestor;
      }
    } catch (e) {
      if (e is DioException && e.error != null) {
        _errorMessage = e.error.toString();
      } else {
        _errorMessage = 'Failed to update investor: $e';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
