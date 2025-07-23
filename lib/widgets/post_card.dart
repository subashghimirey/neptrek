import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/post_model.dart';
import '../providers/auth_provider.dart';
import '../providers/post_provider.dart';
import '../widgets/comment_card.dart';

class PostCard extends StatefulWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _isCommenting = false;
  final _commentController = TextEditingController();
  String? _replyingTo;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _handleLike() {
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    postProvider.likePost(widget.post.id, authProvider.token!);
  }

  void _toggleCommentSection() {
    setState(() {
      _isCommenting = !_isCommenting;
      _replyingTo = null;
    });
  }

  void _handleReply(String commentId) {
    setState(() {
      _isCommenting = true;
      _replyingTo = commentId;
    });
  }

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final postProvider = Provider.of<PostProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (widget.post.id != null) {
      final comment = await postProvider.addComment(
        widget.post.id!,
        _commentController.text.trim(),
        authProvider.token!,
        parentId: _replyingTo != null ? int.parse(_replyingTo!) : null,
      );

      if (comment != null) {
        _commentController.clear();
        setState(() {
          _replyingTo = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author info
          ListTile(
            leading: CircleAvatar(
              backgroundImage: widget.post.authorImage != null 
                ? NetworkImage(widget.post.authorImage!) 
                : null,
              child: widget.post.authorImage == null 
                ? Text((widget.post.authorName ?? 'U')[0].toUpperCase())
                : null,
            ),
            title: Text(widget.post.authorName ?? 'Unknown'),
            subtitle: Text(_formatDate(widget.post.createdAt)),
          ),

          // Post content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(widget.post.content),
          ),

          // Post images
          if (widget.post.images.isNotEmpty)
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.post.images.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        widget.post.images[index],
                        fit: BoxFit.cover,
                        height: 200,
                        width: 200,
                      ),
                    ),
                  );
                },
              ),
            ),

          // Like and comment buttons
          Row(
            children: [
              IconButton(
                icon: Icon(
                  widget.post.isLiked ? Icons.favorite : Icons.favorite_border,
                  color: widget.post.isLiked ? Colors.red : null,
                ),
                onPressed: _handleLike,
              ),
              Text('${widget.post.likesCount}'),
              IconButton(
                icon: const Icon(Icons.comment_outlined),
                onPressed: _toggleCommentSection,
              ),
              Text('${widget.post.commentsCount}'),
            ],
          ),

          // Comments section
          if (_isCommenting) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: _replyingTo != null 
                          ? 'Write a reply...' 
                          : 'Write a comment...',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _submitComment,
                  ),
                ],
              ),
            ),
            if (_replyingTo != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Text(
                      'Replying to comment',
                      style: TextStyle(color: Colors.blue[700]),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _replyingTo = null;
                        });
                      },
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.post.comments.length,
              itemBuilder: (context, index) {
                final comment = widget.post.comments[index];
                return Column(
                  children: [
                    CommentCard(
                      comment: comment,
                      onReply: _handleReply,
                    ),
                    ...comment.replies.map((reply) => CommentCard(
                      comment: reply,
                      isReply: true,
                    )),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final difference = DateTime.now().difference(date);
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}
