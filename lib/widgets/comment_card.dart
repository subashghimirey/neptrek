import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/comment_model.dart';
import '../providers/post_provider.dart';

class CommentCard extends StatelessWidget {
  final Comment comment;
  final bool isReply;
  final Function(String)? onReply;

  const CommentCard({
    super.key,
    required this.comment,
    this.isReply = false,
    this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: isReply ? 32.0 : 0.0, bottom: 8.0),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: comment.userAvatar != null 
                    ? NetworkImage(comment.userAvatar!)
                    : null,
                  child: comment.userAvatar == null 
                    ? Text(comment.username[0].toUpperCase())
                    : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        comment.content,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0, left: 40.0),
              child: Row(
                children: [
                  Text(
                    comment.timeAgo,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  if (!isReply && onReply != null) ...[
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () => onReply!(comment.id.toString()),
                      child: Text(
                        'Reply',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
