import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/admin_model.dart';
import 'package:investrack_admin/services/api_service.dart';

class AuthController extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  Admin? _currentAdmin;
  bool _isLoading = false;
  String? _errorMessage;

  Admin? get currentAdmin => _currentAdmin;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentAdmin != null;

  Future<bool> login(String username, String password) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final response = await _apiService.client.post('/auth/admin/login', data: {
        'username': username,
        'password': password,
      });
      
      final data = response.data;
      if (data != null && data['access_token'] != null) {
        final token = data['access_token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);

        final userData = data['user'];
        _currentAdmin = Admin(
          id: userData['id'] ?? 'unknown',
          username: userData['username'] ?? username,
          role: userData['role'] ?? 'Admin',
          createdAt: DateTime.now(),
        );
        _setLoading(false);
        return true;
      } else {
        _errorMessage = 'Invalid response from server.';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = 'Invalid username or password.';
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    _currentAdmin = null;
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    if (token != null) {
      // For now, we just mock the admin details if token exists
      // In a full implementation, you might want to call a /auth/admin/me endpoint
      _currentAdmin = Admin(
        id: 'cached-admin',
        username: 'admin',
        role: 'Admin',
        createdAt: DateTime.now(),
      );
    }
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
