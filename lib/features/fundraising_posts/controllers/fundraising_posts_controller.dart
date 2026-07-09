import 'package:flutter/foundation.dart';
import '../models/fundraising_post_model.dart';
import '../repositories/fundraising_posts_repository.dart';
import 'package:investrack_admin/features/revisions/controllers/revisions_controller.dart';
import 'package:investrack_admin/utils/error_handler.dart';

class FundraisingPostsController extends ChangeNotifier {
  final FundraisingPostsRepository _repository = FundraisingPostsRepository();

  List<FundraisingPost> _posts = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<FundraisingPost> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadPosts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _posts = await _repository.getPosts();
    } catch (e) {
      _errorMessage = ErrorHandler.getErrorMessage(e, defaultMessage: 'Failed to load posts');
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
      final post = await _repository.getPost(slug);
      _isLoading = false;
      notifyListeners();
      return post;
    } catch (e) {
      _errorMessage = ErrorHandler.getErrorMessage(e, defaultMessage: 'Failed to load post details');
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
      await _repository.updatePost(id, data);
      await loadPosts();
      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.getErrorMessage(e, defaultMessage: 'Failed to update post');
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
      await _repository.updatePostStatus(id, status, adminFeedback);
      await loadPosts();
      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.getErrorMessage(e, defaultMessage: 'Failed to update post status');
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
      await _repository.deletePost(id);
      await loadPosts();
      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.getErrorMessage(e, defaultMessage: 'Failed to delete post');
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
      return await _repository.getComments(postId);
    } catch (e) {
      _errorMessage = ErrorHandler.getErrorMessage(e, defaultMessage: 'Failed to load comments');
      return [];
    }
  }

  Future<bool> deleteComment(String commentId) async {
    try {
      await _repository.deleteComment(commentId);
      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.getErrorMessage(e, defaultMessage: 'Failed to delete comment');
      return false;
    }
  }

  Future<bool> updateComment(String commentId, String newContent) async {
    try {
      await _repository.updateComment(commentId, newContent);
      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.getErrorMessage(e, defaultMessage: 'Failed to update comment');
      return false;
    }
  }

  Future<String?> uploadCoverImage(dynamic fileBytes, String fileName) async {
    try {
      return await _repository.uploadCoverImage(fileBytes, fileName);
    } catch (e) {
      if (kDebugMode) {
        print('Upload failed: $e');
      }
      return null;
    }
  }
}
