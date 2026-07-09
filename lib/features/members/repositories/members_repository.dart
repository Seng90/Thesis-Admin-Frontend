import 'package:investrack_admin/services/api_service.dart';
import '../models/member_model.dart';
import '../models/member_log_model.dart';

class MembersRepository {
  final ApiService _apiService = ApiService();

  Future<List<Member>> getMembers() async {
    final response = await _apiService.client.get('/admin/members');
    final List<dynamic> data = response.data;
    return data.map((json) => Member.fromJson(json)).toList();
  }

  Future<void> blockMember(String id) async {
    await _apiService.client.patch('/admin/members/$id', data: {'status': 'Blocked'});
  }

  Future<void> changeRole(String id, String role) async {
    await _apiService.client.patch('/admin/members/$id/role', data: {'role': role});
  }

  Future<void> updateMember(String id, Map<String, dynamic> data) async {
    await _apiService.client.patch('/admin/members/$id', data: data);
  }

  Future<List<Map<String, dynamic>>> getManagedCompanies(String memberId) async {
    final response = await _apiService.client.get('/admin/members/$memberId/companies');
    final List<dynamic> data = response.data;
    return data.map((json) => json as Map<String, dynamic>).toList();
  }

  Future<List<MemberLog>> getGlobalLogs() async {
    final response = await _apiService.client.get('/admin/manage-members');
    final List<dynamic> data = response.data;
    return data.map((json) => MemberLog.fromJson(json)).toList();
  }

  Future<List<MemberLog>> getMemberLogs(String memberId) async {
    final response = await _apiService.client.get(
      '/admin/manage-members',
      queryParameters: {'memberId': memberId},
    );
    final List<dynamic> data = response.data;
    return data.map((json) => MemberLog.fromJson(json)).toList();
  }

  Future<void> checkExpiry() async {
    await _apiService.client.post('/admin/members/check-expiry');
  }
}
