import 'package:flutter/material.dart';
import '../models/admin_model.dart';
import '../repositories/admins_repository.dart';
import 'package:investrack_admin/utils/error_handler.dart';

class AdminsController extends ChangeNotifier {
  final AdminsRepository _repository = AdminsRepository();

  List<Admin> admins = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadAdmins() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final data = await _repository.getAdmins();
      admins = data.map<Admin>((json) => Admin.fromJson(json)).toList();
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createAdmin(Map<String, dynamic> data) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _repository.createAdmin(data);
      await loadAdmins();
    } catch (e) {
      _handleError(e);
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateAdmin(String id, Map<String, dynamic> data) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _repository.updateAdmin(id, data);
      await loadAdmins();
    } catch (e) {
      _handleError(e);
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteAdmin(String id) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteAdmin(id);
      await loadAdmins();
    } catch (e) {
      _handleError(e);
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _handleError(dynamic error) {
    errorMessage = ErrorHandler.getErrorMessage(error);
  }
}
