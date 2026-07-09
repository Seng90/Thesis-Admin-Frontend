import 'package:flutter/material.dart';
import '../models/package_model.dart';
import '../repositories/packages_repository.dart';
import 'package:investrack_admin/utils/error_handler.dart';

class PackagesController extends ChangeNotifier {
  final PackagesRepository _repository = PackagesRepository();

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
      _packages = await _repository.getPackages();
    } catch (e) {
      _errorMessage = ErrorHandler.getErrorMessage(e, defaultMessage: 'Failed to load packages');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deletePackage(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.deletePackage(id);
      _packages.removeWhere((p) => p.id == id);
      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.getErrorMessage(e, defaultMessage: 'Failed to delete package');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addPackage(Package package) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = package.toJson()
        ..remove('id')
        ..remove('created_at');
      final created = await _repository.createPackage(data);
      _packages.add(created);
      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.getErrorMessage(e, defaultMessage: 'Failed to add package');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updatePackage(Package updatedPackage) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = updatedPackage.toJson()
        ..remove('id')
        ..remove('created_at');
      final updated = await _repository.updatePackage(updatedPackage.id, data);
      final index = _packages.indexWhere((p) => p.id == updatedPackage.id);
      if (index != -1) {
        _packages[index] = updated;
      }
      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.getErrorMessage(e, defaultMessage: 'Failed to update package');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
