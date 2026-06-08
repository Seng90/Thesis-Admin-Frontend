import 'package:flutter/foundation.dart';
import 'package:investrack_admin/services/api_service.dart';

import '../models/founder_model.dart';

class FoundersController extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
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
      final response = await _apiService.client.get('/admin/founders');
      final List<dynamic> data = response.data;
      _founders = data.map((json) => Founder.fromJson(json)).toList();
    } catch (e) {
      if (e is DioException && e.error != null) {
        _errorMessage = e.error.toString();
      } else {
        _errorMessage = 'Failed to load founders: $e';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteFounder(String id) async {
    try {
      await _apiService.client.delete('/admin/founders/$id');
      _founders.removeWhere((f) => f.id == id);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete founder: $e';
      notifyListeners();
    }
  }
}
