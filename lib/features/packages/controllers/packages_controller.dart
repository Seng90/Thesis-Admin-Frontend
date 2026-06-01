import 'package:flutter/material.dart';
import '../models/package_model.dart';
import 'package:investrack_admin/services/api_service.dart';

class PackagesController extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Package> _packages = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Package> get packages => _packages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadPackages() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.client.get('/admin/packages');
      final List<dynamic> data = response.data;
      _packages = data.map((json) => Package.fromJson(json)).toList();
    } catch (e) {
      _errorMessage = 'Failed to load packages: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deletePackage(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.client.delete('/admin/packages/$id');
      _packages.removeWhere((p) => p.id == id);
    } catch (e) {
      _errorMessage = 'Failed to delete package: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addPackage(Package package) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = package.toJson()..remove('id')..remove('created_at');
      // Convert price to Decimal/double on backend if needed, toJson already produces double
      final response = await _apiService.client.post('/admin/packages', data: data);
      final newPackage = Package.fromJson(response.data);
      _packages.add(newPackage);
    } catch (e) {
      _errorMessage = 'Failed to add package: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePackage(Package updatedPackage) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = updatedPackage.toJson()..remove('id')..remove('created_at');
      await _apiService.client.patch('/admin/packages/${updatedPackage.id}', data: data);
      final index = _packages.indexWhere((p) => p.id == updatedPackage.id);
      if (index != -1) {
        _packages[index] = updatedPackage;
      }
    } catch (e) {
      _errorMessage = 'Failed to update package: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
