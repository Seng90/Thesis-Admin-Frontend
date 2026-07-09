import 'package:flutter/material.dart';
import '../models/founder_model.dart';
import '../repositories/founders_repository.dart';
import 'package:investrack_admin/utils/error_handler.dart';

class FoundersController extends ChangeNotifier {
  final FoundersRepository _repository = FoundersRepository();

  List<Founder> _founders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Founder> get founders => _founders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchFounders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _founders = await _repository.getFounders();
    } catch (e) {
      _errorMessage = ErrorHandler.getErrorMessage(e, defaultMessage: 'Failed to load founders');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteFounder(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteFounder(id);
      _founders.removeWhere((f) => f.id == id);
      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.getErrorMessage(e, defaultMessage: 'Failed to delete founder');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
