import 'package:investrack_admin/services/api_service.dart';

class AuthRepository {
  final ApiService _apiService = ApiService();

  Future<Response> login(String email, String password) async {
    return _apiService.client.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
  }

  Future<Response> getProfile() async {
    return _apiService.client.get('/auth/me');
  }
}
