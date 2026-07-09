import 'package:investrack_admin/services/api_service.dart';
import '../models/revision_model.dart';

class RevisionsRepository {
  final ApiService _apiService = ApiService();

  Future<List<Revision>> getPendingRevisions() async {
    final response = await _apiService.client.get('/admin/revisions/pending');
    final List<dynamic> data = response.data;
    return data.map((json) => Revision.fromJson(json)).toList();
  }

  Future<void> createRevision(String entityType, String? entityId, Map<String, dynamic> changes) async {
    await _apiService.client.post(
      '/admin/revisions',
      data: {
        'entity_type': entityType,
        'entity_id': entityId,
        'proposed_changes': changes,
      },
    );
  }

  Future<void> approveRevision(String id) async {
    await _apiService.client.patch('/admin/revisions/$id/approve');
  }

  Future<void> rejectRevision(String id) async {
    await _apiService.client.patch('/admin/revisions/$id/reject');
  }

  Future<void> partialApproveRevision(String id, Map<String, dynamic> decisions, String? note) async {
    await _apiService.client.patch(
      '/admin/revisions/$id/partial-approve',
      data: {
        'fieldDecisions': decisions,
        'adminNote': note,
      },
    );
  }
}
