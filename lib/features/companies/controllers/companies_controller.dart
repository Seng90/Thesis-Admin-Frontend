import 'package:flutter/material.dart';
import '../models/company_model.dart';
import '../repositories/companies_repository.dart';
import 'package:investrack_admin/utils/error_handler.dart';

class CompaniesController extends ChangeNotifier {
  final CompaniesRepository _repository = CompaniesRepository();

  List<Company> _companies = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Company> get companies => _companies;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadCompanies() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _companies = await _repository.getCompanies();
    } catch (e) {
      _errorMessage = ErrorHandler.getErrorMessage(e, defaultMessage: 'Failed to load companies');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateCompanyStatus(String id, String newStatus) async {
    try {
      final updated = await _repository.updateCompany(id, {'status': newStatus});
      final index = _companies.indexWhere((c) => c.id == id);
      if (index != -1) {
        _companies[index] = updated;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.getErrorMessage(e, defaultMessage: 'Failed to update company status');
      notifyListeners();
      return false;
    }
  }

  Future<bool> addCompany(Company company) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = company.toJson()..remove('id')..remove('approved_by');
      final created = await _repository.createCompany(data);
      _companies.add(created);
      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.getErrorMessage(e, defaultMessage: 'Failed to add company');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateCompany(Company updatedCompany) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = updatedCompany.toJson()
        ..remove('id')
        ..remove('approved_by');
      final updated = await _repository.updateCompany(updatedCompany.id, data);
      final index = _companies.indexWhere((c) => c.id == updatedCompany.id);
      if (index != -1) {
        _companies[index] = updated;
      }
      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.getErrorMessage(e, defaultMessage: 'Failed to update company');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteCompany(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteCompany(id);
      _companies.removeWhere((c) => c.id == id);
      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.getErrorMessage(e, defaultMessage: 'Failed to delete company');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> uploadCompanyLogo(dynamic fileBytes, String fileName) async {
    try {
      return await _repository.uploadCompanyLogo(fileBytes, fileName);
    } catch (e) {
      _errorMessage = ErrorHandler.getErrorMessage(e, defaultMessage: 'Failed to upload logo');
      notifyListeners();
      return null;
    }
  }
}
