import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:investrack_admin/services/api_service.dart';
import '../models/revision_model.dart';

class RevisionsController extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Revision> _pendingRevisions = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Revision> get pendingRevisions => _pendingRevisions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadPendingRevisions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.client.get('/admin/revisions/pending');
      final List<dynamic> data = response.data;
      _pendingRevisions = data.map((json) => Revision.fromJson(json)).toList();
    } catch (e) {
      if (e is DioException && e.error != null) {
        _errorMessage = e.error.toString();
      } else {
        _errorMessage = 'Failed to load revisions: $e';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createRevision({
    required String entityType,
    required String? entityId,
    required Map<String, dynamic> proposedChanges,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.client.post(
        '/admin/revisions',
        data: {
          'entity_type': entityType,
          'entity_id': entityId,
          'proposed_changes': proposedChanges,
        },
      );
      // Optionally reload pending revisions
      await loadPendingRevisions();
      return true;
    } catch (e) {
      if (e is DioException && e.error != null) {
        _errorMessage = e.error.toString();
      } else {
        _errorMessage = 'Failed to create revision: $e';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> approveRevision(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.client.patch('/admin/revisions/$id/approve');
      _pendingRevisions.removeWhere((r) => r.id == id);
      return true;
    } catch (e) {
      if (e is DioException && e.error != null) {
        _errorMessage = e.error.toString();
      } else {
        _errorMessage = 'Failed to approve revision: $e';
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> rejectRevision(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.client.patch('/admin/revisions/$id/reject');
      _pendingRevisions.removeWhere((r) => r.id == id);
      return true;
    } catch (e) {
      if (e is DioException && e.error != null) {
        _errorMessage = e.error.toString();
      } else {
        _errorMessage = 'Failed to reject revision: $e';
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> partialApproveRevision(
    String id,
    Map<String, dynamic> fieldDecisions,
    String? adminNote,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.client.patch(
        '/admin/revisions/$id/partial-approve',
        data: {
          'fieldDecisions': fieldDecisions,
          'adminNote': adminNote,
        },
      );
      _pendingRevisions.removeWhere((r) => r.id == id);
      return true;
    } catch (e) {
      if (e is DioException && e.error != null) {
        _errorMessage = e.error.toString();
      } else {
        _errorMessage = 'Failed to partially approve revision: $e';
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
