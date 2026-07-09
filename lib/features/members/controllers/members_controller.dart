import 'package:flutter/material.dart';
import '../models/member_model.dart';
import '../models/member_log_model.dart';
import '../repositories/members_repository.dart';
import 'package:investrack_admin/utils/error_handler.dart';

class MembersController extends ChangeNotifier {
  final MembersRepository _repository = MembersRepository();

  List<Member> _members = [];
  List<MemberLog> _globalLogs = [];
  bool _isLoading = false;
  bool _isLoadingLogs = false;
  String? _errorMessage;

  List<Member> get members => _members;
  List<MemberLog> get globalLogs => _globalLogs;
  bool get isLoading => _isLoading;
  bool get isLoadingLogs => _isLoadingLogs;
  String? get errorMessage => _errorMessage;

  Future<void> loadMembers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _members = await _repository.getMembers();
    } catch (e) {
      _errorMessage = ErrorHandler.getErrorMessage(e, defaultMessage: 'Failed to load members');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> blockMember(String id) async {
    try {
      await _repository.blockMember(id);
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
      _errorMessage = ErrorHandler.getErrorMessage(e, defaultMessage: 'Failed to block member');
    } finally {
      notifyListeners();
    }
  }

  Future<bool> changeRole(String id, String newRole) async {
    try {
      await _repository.changeRole(id, newRole);
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
      _errorMessage = ErrorHandler.getErrorMessage(e, defaultMessage: 'Failed to change role');
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
      await _repository.updateMember(updatedMember.id, data);
      final index = _members.indexWhere((m) => m.id == updatedMember.id);
      if (index != -1) {
        _members[index] = updatedMember;
      }
    } catch (e) {
      _errorMessage = ErrorHandler.getErrorMessage(e, defaultMessage: 'Failed to update member');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Map<String, dynamic>>> getManagedCompanies(String memberId) async {
    try {
      return await _repository.getManagedCompanies(memberId);
    } catch (e) {
      return [];
    }
  }

  Future<void> loadGlobalLogs() async {
    _isLoadingLogs = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _globalLogs = await _repository.getGlobalLogs();
    } catch (e) {
      _errorMessage = ErrorHandler.getErrorMessage(e, defaultMessage: 'Failed to load audit logs');
    } finally {
      _isLoadingLogs = false;
      notifyListeners();
    }
  }

  Future<List<MemberLog>> fetchMemberLogs(String memberId) async {
    try {
      return await _repository.getMemberLogs(memberId);
    } catch (e) {
      return [];
    }
  }

  Future<bool> checkExpiry() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.checkExpiry();
      await loadMembers();
      await loadGlobalLogs();
      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.getErrorMessage(e, defaultMessage: 'Failed to check expiry');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
