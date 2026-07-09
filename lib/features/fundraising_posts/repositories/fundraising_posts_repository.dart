import 'package:investrack_admin/services/api_service.dart';
import '../models/fundraising_post_model.dart';

class FundraisingPostsRepository {
  final ApiService _apiService = ApiService();

  Future<List<FundraisingPost>> getPosts() async {
    final response = await _apiService.client.get('/admin/fundraising-posts');
    final List<dynamic> data = response.data;
    return data.map((json) => FundraisingPost.fromJson(json)).toList();
  }

  Future<FundraisingPost> getPost(String slug) async {
    final response = await _apiService.client.get('/admin/fundraising-posts/$slug');
    return FundraisingPost.fromJson(response.data);
  }

  Future<void> updatePost(String id, Map<String, dynamic> data) async {
    await _apiService.client.patch('/admin/fundraising-posts/$id', data: data);
  }

  Future<void> updatePostStatus(String id, String status, String? feedback) async {
    final data = <String, dynamic>{'status': status};
    if (feedback != null && feedback.isNotEmpty) {
      data['admin_feedback'] = feedback;
    }
    await _apiService.client.patch('/admin/fundraising-posts/$id/status', data: data);
  }

  Future<void> deletePost(String id) async {
    await _apiService.client.delete('/admin/fundraising-posts/$id');
  }

  Future<List<dynamic>> getComments(String postId) async {
    final response = await _apiService.client.get('/user/fundraising-posts/$postId/comments');
    return response.data as List<dynamic>;
  }

  Future<void> deleteComment(String commentId) async {
    await _apiService.client.delete('/admin/comments/$commentId');
  }

  Future<void> updateComment(String commentId, String content) async {
    await _apiService.client.patch('/admin/comments/$commentId', data: {'content': content});
  }

  Future<String?> uploadCoverImage(dynamic fileBytes, String fileName) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(fileBytes, filename: fileName),
    });
    final response = await _apiService.client.post('/upload', data: formData);
    return response.data['url'];
  }
}
