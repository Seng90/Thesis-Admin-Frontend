import 'package:flutter/material.dart';
import '../models/company_model.dart';
import 'package:investrack_admin/services/api_service.dart';

class CompaniesController extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
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
      final response = await _apiService.client.get('/admin/companies');
      final List<dynamic> data = response.data is List ? response.data : [];
      _companies = data.map((json) => Company.fromJson(json)).toList();
    } catch (e) {
      if (e is DioException && e.error != null) {
        _errorMessage = e.error.toString();
      } else {
        _errorMessage = 'Failed to load companies: $e';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCompanyStatus(String id, String newStatus) async {
    try {
      await _apiService.client.patch('/admin/companies/$id', data: {
        'status': newStatus,
      });
      final index = _companies.indexWhere((c) => c.id == id);
      if (index != -1) {
        final old = _companies[index];
        _companies[index] = Company(
          id: old.id,
          name: old.name,
          description: old.description,
          industry: old.industry,
          location: old.location,
          contactEmail: old.contactEmail,
          status: newStatus,
          viewCount: old.viewCount,
          foundedDate: old.foundedDate,
          logoUrl: old.logoUrl,
          websiteUrl: old.websiteUrl,
          approvedBy: old.approvedBy,
          createdAt: old.createdAt,
          updatedAt: old.updatedAt,
        );
        notifyListeners();
      }
    } catch (e) {
      if (e is DioException && e.error != null) {
        _errorMessage = e.error.toString();
      } else {
        _errorMessage = 'Failed to update company status: $e';
      }
      notifyListeners();
    }
  }

  Future<void> addCompany(Company company) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = company.toJson()..remove('id');
      final response = await _apiService.client.post('/admin/companies', data: data);
      final newCompany = Company.fromJson(response.data);
      _companies.add(newCompany);
    } catch (e) {
      if (e is DioException && e.error != null) {
        _errorMessage = e.error.toString();
      } else {
        _errorMessage = 'Failed to add company: $e';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCompany(Company updatedCompany) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = updatedCompany.toJson()
        ..remove('id')
        ..remove('approved_by');
      await _apiService.client.patch('/admin/companies/${updatedCompany.id}', data: data);
      final index = _companies.indexWhere((c) => c.id == updatedCompany.id);
      if (index != -1) {
        _companies[index] = updatedCompany;
      }
    } catch (e) {
      if (e is DioException && e.error != null) {
        _errorMessage = e.error.toString();
      } else {
        _errorMessage = 'Failed to update company: $e';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteCompany(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.client.delete('/admin/companies/$id');
      _companies.removeWhere((c) => c.id == id);
    } catch (e) {
      if (e is DioException && e.error != null) {
        _errorMessage = e.error.toString();
      } else {
        _errorMessage = 'Failed to delete company: $e';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
