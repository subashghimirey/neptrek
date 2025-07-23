class Comment {
  final int id;
  final int postId;
  final String content;
  final String username;
  final String? userAvatar;
  final DateTime createdAt;
  final int? parentId;
  final List<Comment> replies;

  const Comment({
    required this.id,
    required this.postId,
    required this.content,
    required this.username,
    this.userAvatar,
    required this.createdAt,
    this.parentId,
    this.replies = const [],
  });

  factory Comment.create({
    required int postId,
    required String content,
    required String username,
    int? parentId,
  }) {
    return Comment(
      id: -1, // Temporary ID for new comments
      postId: postId,
      content: content,
      username: username,
      createdAt: DateTime.now(),
      parentId: parentId,
    );
  }

  Comment copyWith({
    int? id,
    int? postId,
    String? content,
    String? username,
    String? userAvatar,
    DateTime? createdAt,
    int? parentId,
    List<Comment>? replies,
  }) {
    return Comment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      content: content ?? this.content,
      username: username ?? this.username,
      userAvatar: userAvatar ?? this.userAvatar,
      createdAt: createdAt ?? this.createdAt,
      parentId: parentId ?? this.parentId,
      replies: replies ?? this.replies,
    );
  }

  String get timeAgo {
    final difference = DateTime.now().difference(createdAt);
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

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as int,
      postId: json['post'] as int,
      content: json['content'] as String,
      username: json['username'] as String,
      userAvatar: json['user_avatar'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      parentId: json['parent'] as int?,
      replies: (json['replies'] as List<dynamic>?)
          ?.map((reply) => Comment.fromJson(reply as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'post': postId,
      'content': content,
      'parent': parentId,
    };
  }
}
