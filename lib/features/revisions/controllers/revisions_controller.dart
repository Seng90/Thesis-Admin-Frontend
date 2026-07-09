import 'package:flutter/material.dart';
import '../models/revision_model.dart';
import '../repositories/revisions_repository.dart';
import 'package:investrack_admin/utils/error_handler.dart';

class RevisionsController extends ChangeNotifier {
  final RevisionsRepository _repository = RevisionsRepository();

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
      _pendingRevisions = await _repository.getPendingRevisions();
    } catch (e) {
      _errorMessage = ErrorHandler.getErrorMessage(e, defaultMessage: 'Failed to load revisions');
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
      await _repository.createRevision(entityType, entityId, proposedChanges);
      await loadPendingRevisions();
      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.getErrorMessage(e, defaultMessage: 'Failed to create revision');
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
      await _repository.approveRevision(id);
      _pendingRevisions.removeWhere((r) => r.id == id);
      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.getErrorMessage(e, defaultMessage: 'Failed to approve revision');
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
      await _repository.rejectRevision(id);
      _pendingRevisions.removeWhere((r) => r.id == id);
      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.getErrorMessage(e, defaultMessage: 'Failed to reject revision');
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
      await _repository.partialApproveRevision(id, fieldDecisions, adminNote);
      _pendingRevisions.removeWhere((r) => r.id == id);
      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.getErrorMessage(e, defaultMessage: 'Failed to partially approve revision');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
