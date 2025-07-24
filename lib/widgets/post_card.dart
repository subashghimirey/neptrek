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
    final token = authProvider.token;
    
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to like posts')),
      );
      return;
    }
    
    postProvider.likePost(widget.post.id, token);
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

  String? _validateComment(String value) {
    value = value.trim();
    if (value.isEmpty) {
      return 'Comment cannot be empty';
    }
    if (value.length > 500) {
      return 'Comment is too long (max 500 characters)';
    }
    return null;
  }

  Future<void> _submitComment() async {
    final comment = _commentController.text;
    final error = _validateComment(comment);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    final postProvider = Provider.of<PostProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    final user = authProvider.user;
    
    if (token == null || user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to comment')),
      );
      return;
    }

    try {
      if (widget.post.id > 0) {  // Since we made id non-nullable and default to -1
        final comment = await postProvider.addComment(
          widget.post.id,
          _commentController.text.trim(),
          token,
          user: PostUser(
            id: user.user.id,
            displayName: user.displayName,
            photoUrl: user.photoUrl,
          ),
          parentId: _replyingTo != null ? int.tryParse(_replyingTo!) : null,
        );

        if (comment != null) {
          _commentController.clear();
          setState(() {
            _replyingTo = null;
            _isCommenting = false;  // Hide comment section after successful comment
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add comment: ${e.toString()}')),
      );
    }
  }

  void _showFullScreenImage(BuildContext context, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: PageView.builder(
            itemCount: widget.post.images.length,
            controller: PageController(initialPage: initialIndex),
            itemBuilder: (context, index) {
              return Center(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Hero(
                    tag: '${widget.post.id}_image_$index',
                    child: Image.network(
                      widget.post.images[index],
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author info and trek info
          Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: widget.post.user.photoUrl.isNotEmpty
                    ? NetworkImage(widget.post.user.photoUrl)
                    : null,
                  child: widget.post.user.photoUrl.isEmpty
                    ? Text(widget.post.user.displayName[0].toUpperCase())
                    : null,
                ),
                title: Row(
                  children: [
                    Text(
                      widget.post.user.displayName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                subtitle: Row(
                  children: [
                    Text(_formatDate(widget.post.createdAt)),
                    if (widget.post.location != null) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.location_on, size: 14, color: Colors.blue[700]),
                      const SizedBox(width: 4),
                      Text(
                        widget.post.location!.placeName ?? 'Unknown location',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    if (widget.post.trekName.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.hiking, size: 14, color: Colors.green[700]),
                      const SizedBox(width: 4),
                      Text(
                        widget.post.trekName,
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
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
                    child: GestureDetector(
                      onTap: () => _showFullScreenImage(context, index),
                      child: Hero(
                        tag: '${widget.post.id}_image_$index',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            widget.post.images[index],
                            fit: BoxFit.cover,
                            height: 200,
                            width: 200,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 200,
                                width: 200,
                                color: Colors.grey[200],
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 200,
                                width: 200,
                                color: Colors.grey[300],
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.error),
                                    SizedBox(height: 8),
                                    Text('Failed to load image'),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          // Like and comment buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    widget.post.isLiked ? Icons.favorite : Icons.favorite_border,
                    color: widget.post.isLiked ? Colors.red : null,
                  ),
                  onPressed: _handleLike,
                ),
                Text('${widget.post.likesCount}'),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.comment_outlined),
                  onPressed: _toggleCommentSection,
                ),
                Text('${widget.post.commentsCount}'),
              ],
            ),
          ),

          // Comments section
          if (_isCommenting) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _commentController,
                      maxLength: 500,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: _replyingTo != null 
                          ? 'Write a reply...' 
                          : 'Write a comment...',
                        border: const OutlineInputBorder(),
                        counterText: '${_commentController.text.length}/500',
                        errorText: _validateComment(_commentController.text),
                      ),
                      onFieldSubmitted: (_) => _submitComment(),
                      onChanged: (_) => setState(() {}),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommentCard(
                      comment: comment,
                      onReply: _handleReply,
                    ),
                    if (comment.replies.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 32.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: comment.replies.map((reply) => CommentCard(
                            comment: reply,
                            isReply: true,
                          )).toList(),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
