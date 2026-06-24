import 'package:flutter/foundation.dart';
import 'package:investrack_admin/services/api_service.dart';
import '../models/fundraising_post_model.dart';
import 'package:investrack_admin/features/revisions/controllers/revisions_controller.dart';

class FundraisingPostsController extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<FundraisingPost> _posts = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<FundraisingPost> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String _parseError(dynamic e) {
    if (e is DioException && e.response?.data != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic> && data['message'] != null) {
        final message = data['message'];
        if (message is List) return message.join(', ');
        return message.toString();
      }
      return e.message ?? 'Unknown network error';
    }
    return e.toString();
  }

  Future<void> loadPosts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.client.get('/admin/fundraising-posts');
      final List<dynamic> data = response.data;
      _posts = data.map((json) => FundraisingPost.fromJson(json)).toList();
    } catch (e) {
      _errorMessage = 'Failed to load posts: ${_parseError(e)}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<FundraisingPost?> getPostBySlug(String slug) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.client.get(
        '/admin/fundraising-posts/$slug',
      );
      _isLoading = false;
      notifyListeners();
      return FundraisingPost.fromJson(response.data);
    } catch (e) {
      _errorMessage = 'Failed to load post details: ${_parseError(e)}';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> updatePost(String id, Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.client.patch(
        '/admin/fundraising-posts/$id',
        data: data,
      );
      await loadPosts();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update post: ${_parseError(e)}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePostStatus(
    String id,
    String status, {
    String? adminFeedback,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = <String, dynamic>{'status': status};
      if (adminFeedback != null && adminFeedback.isNotEmpty) {
        data['admin_feedback'] = adminFeedback;
      }

      await _apiService.client.patch(
        '/admin/fundraising-posts/$id/status',
        data: data,
      );
      await loadPosts();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update post status: ${_parseError(e)}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> directDeletePost(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.client.delete('/admin/fundraising-posts/$id');
      await loadPosts();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete post: ${_parseError(e)}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> requestDeletePost(
    RevisionsController revisionsController,
    String id,
  ) async {
    return await revisionsController.createRevision(
      entityType: 'FundraisingPost',
      entityId: id,
      proposedChanges: {'_action': 'delete'},
    );
  }

  Future<bool> requestUpdatePost(
    RevisionsController revisionsController,
    String id,
    Map<String, dynamic> data,
  ) async {
    return await revisionsController.createRevision(
      entityType: 'FundraisingPost',
      entityId: id,
      proposedChanges: data,
    );
  }

  Future<List<dynamic>> getPostComments(String postId) async {
    try {
      final response = await _apiService.client.get(
        '/user/fundraising-posts/$postId/comments',
      );
      return response.data as List<dynamic>;
    } catch (e) {
      _errorMessage = 'Failed to load comments: ${_parseError(e)}';
      return [];
    }
  }

  Future<bool> deleteComment(String commentId) async {
    try {
      await _apiService.client.delete('/admin/comments/$commentId');
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete comment: ${_parseError(e)}';
      return false;
    }
  }

  Future<bool> updateComment(String commentId, String newContent) async {
    try {
      await _apiService.client.patch(
        '/admin/comments/$commentId',
        data: {'content': newContent},
      );
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update comment: ${_parseError(e)}';
      return false;
    }
  }

  Future<String?> uploadCoverImage(dynamic fileBytes, String fileName) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(fileBytes, filename: fileName),
      });
      final response = await _apiService.client.post('/upload', data: formData);
      return response.data['url'];
    } catch (e) {
      if (kDebugMode) {
        print('Upload failed: $e');
      }
      return null;
    }
  }
}
