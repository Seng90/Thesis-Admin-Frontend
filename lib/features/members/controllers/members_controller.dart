import 'package:flutter/material.dart';
import '../models/member_model.dart';
import 'package:investrack_admin/services/api_service.dart';

class MembersController extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Member> _members = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Member> get members => _members;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadMembers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.client.get('/admin/members');
      final List<dynamic> data = response.data;
      _members = data.map((json) => Member.fromJson(json)).toList();
    } catch (e) {
      if (e is DioException && e.error != null) {
        _errorMessage = e.error.toString();
      } else {
        _errorMessage = 'Failed to load members: $e';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> blockMember(String id) async {
    try {
      await _apiService.client.patch(
        '/admin/members/$id',
        data: {'status': 'Blocked'},
      );
      final index = _members.indexWhere((m) => m.id == id);
      if (index != -1) {
        final old = _members[index];
        _members[index] = Member(
          id: old.id,
          username: old.username,
          email: old.email,
          status: 'Blocked',
          packageId: old.packageId,
          avatarUrl: old.avatarUrl,
          role: old.role,
          expiryDate: old.expiryDate,
          createdAt: old.createdAt,
          updatedAt: old.updatedAt,
        );
        notifyListeners();
      }
    } catch (e) {
      if (e is DioException && e.error != null) {
        _errorMessage = e.error.toString();
      } else {
        _errorMessage = 'Failed to block member: $e';
      }
    } finally {
      notifyListeners();
    }
  }

  Future<bool> changeRole(String id, String newRole) async {
    try {
      await _apiService.client.patch(
        '/admin/members/$id/role',
        data: {'role': newRole},
      );
      final index = _members.indexWhere((m) => m.id == id);
      if (index != -1) {
        final old = _members[index];
        _members[index] = Member(
          id: old.id,
          username: old.username,
          email: old.email,
          status: old.status,
          packageId: old.packageId,
          avatarUrl: old.avatarUrl,
          role: newRole,
          expiryDate: old.expiryDate,
          createdAt: old.createdAt,
          updatedAt: old.updatedAt,
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      if (e is DioException && e.error != null) {
        _errorMessage = e.error.toString();
      } else {
        _errorMessage = 'Failed to change role: $e';
      }
      notifyListeners();
      return false;
    }
  }

  Future<void> updateMember(Member updatedMember) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = updatedMember.toJson()
        ..remove('id')
        ..remove('created_at');
      await _apiService.client.patch(
        '/admin/members/${updatedMember.id}',
        data: data,
      );
      final index = _members.indexWhere((m) => m.id == updatedMember.id);
      if (index != -1) {
        _members[index] = updatedMember;
      }
    } catch (e) {
      if (e is DioException && e.error != null) {
        _errorMessage = e.error.toString();
      } else {
        _errorMessage = 'Failed to update member: $e';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Map<String, dynamic>>> getManagedCompanies(
    String memberId,
  ) async {
    try {
      final response = await _apiService.client.get(
        '/admin/members/$memberId/companies',
      );
      final List<dynamic> data = response.data;
      return data.map((json) => json as Map<String, dynamic>).toList();
    } catch (e) {
      return [];
    }
  }
}
