import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'package:investrack_admin/services/api_service.dart';

class AuthController extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isCheckingAuth = true;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isCheckingAuth => _isCheckingAuth;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  AuthController() {
    ApiService.onUnauthorized = () {
      logout();
    };
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkAuthStatus();
    });
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final response = await _apiService.client.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      final data = response.data;
      if (data != null && data['access_token'] != null) {
        final token = data['access_token'];
        final refreshToken = data['refresh_token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        if (refreshToken != null) {
          await prefs.setString('refresh_token', refreshToken);
        }

        final userData = data['user'];
        _currentUser = UserModel.fromJson(userData);
        await prefs.setString('user_data', jsonEncode(userData));
        
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Invalid response from server.';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      if (e is DioException && e.error != null) {
        _errorMessage = e.error.toString();
      } else {
        _errorMessage = 'Invalid email or password.';
      }
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('refresh_token');
    await prefs.remove('user_data');
    _currentUser = null;
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    _isCheckingAuth = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userDataString = prefs.getString('user_data');

      if (token != null && userDataString != null) {
        try {
          final userData = jsonDecode(userDataString);
          _currentUser = UserModel.fromJson(userData);
          notifyListeners();
        } catch (_) {
          await logout();
          return;
        }

        // Refresh in background
        _refreshProfileInBackground();
      } else {
        if (_currentUser != null) {
          await logout();
        }
      }
    } catch (_) {
      if (_currentUser != null) {
        await logout();
      }
    } finally {
      _isCheckingAuth = false;
      notifyListeners();
    }
  }

  Future<void> _refreshProfileInBackground() async {
    try {
      final response = await _apiService.client.get('/auth/me');
      if (response.statusCode == 200 && response.data != null) {
        _currentUser = UserModel.fromJson(response.data);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', jsonEncode(response.data));
        notifyListeners();
      }
    } catch (e) {
      // If unauthorized (401), force logout
      if (e is DioException && e.response?.statusCode == 401) {
        await logout();
      }
      // For network errors / server down, we keep the cached profile values gracefully
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
