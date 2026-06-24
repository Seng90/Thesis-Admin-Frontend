import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:investrack_admin/utils/constants.dart';
import '../../controllers/fundraising_posts_controller.dart';

class PostCommentsSection extends StatefulWidget {
  final String postId;
  const PostCommentsSection({super.key, required this.postId});

  @override
  State<PostCommentsSection> createState() => _PostCommentsSectionState();
}

class _PostCommentsSectionState extends State<PostCommentsSection> {
  List<dynamic> _comments = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    setState(() => _isLoading = true);
    final ctrl = context.read<FundraisingPostsController>();
    final comments = await ctrl.getPostComments(widget.postId);
    if (mounted) {
      setState(() {
        _comments = comments;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteComment(String commentId) async {
    final ctrl = context.read<FundraisingPostsController>();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Comment'),
        content: const Text('Are you sure you want to delete this comment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await ctrl.deleteComment(commentId);
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Comment deleted')));
          _loadComments();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(ctrl.errorMessage ?? 'Failed to delete comment'),
            ),
          );
        }
      }
    }
  }

  Future<void> _editComment(String commentId, String currentContent) async {
    final ctrl = context.read<FundraisingPostsController>();
    final textController = TextEditingController(text: currentContent);
    final newContent = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Comment'),
        content: TextField(
          controller: textController,
          maxLines: 4,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, textController.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newContent != null &&
        newContent.trim().isNotEmpty &&
        newContent != currentContent) {
      final success = await ctrl.updateComment(commentId, newContent.trim());
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Comment updated')));
          _loadComments();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(ctrl.errorMessage ?? 'Failed to update comment'),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_comments.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Text(
          'No comments for this post.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _comments.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final comment = _comments[index];
        final member = comment['member'] ?? {};
        final username = member['username'] ?? 'Unknown User';
        final content = comment['content'] ?? '';
        final commentId = comment['id'];

        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            username,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              content,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.edit,
                  size: 20,
                  color: AppColors.primary,
                ),
                tooltip: 'Edit Comment',
                onPressed: () => _editComment(commentId, content),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete,
                  size: 20,
                  color: AppColors.error,
                ),
                tooltip: 'Delete Comment',
                onPressed: () => _deleteComment(commentId),
              ),
            ],
          ),
        );
      },
    );
  }
}
