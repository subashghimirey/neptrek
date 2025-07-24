import 'post_model.dart';

class Comment {
  final int id;
  final int post;
  final PostUser user;
  final String content;
  final int? parent;
  final int likesCount;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Comment> replies;
  final bool isLiked;

  const Comment({
    required this.id,
    required this.post,
    required this.user,
    required this.content,
    this.parent,
    required this.likesCount,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.replies,
    required this.isLiked,
  });

  factory Comment.create({
    required int postId,
    required String content,
    int? parentId,
  }) {
    return Comment(
      id: -1,
      post: postId,
      content: content,
      user: PostUser(id: -1, displayName: '', photoUrl: ''),
      parent: parentId,
      likesCount: 0,
      status: 'active',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      replies: const [],
      isLiked: false,
    );
  }

  Comment copyWith({
    int? id,
    int? post,
    String? content,
    PostUser? user,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? parent,
    List<Comment>? replies,
    int? likesCount,
    bool? isLiked,
    String? status,
  }) {
    return Comment(
      id: id ?? this.id,
      post: post ?? this.post,
      content: content ?? this.content,
      user: user ?? this.user,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      parent: parent ?? this.parent,
      replies: replies ?? this.replies,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
      status: status ?? this.status,
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
      id: json['id'] as int? ?? -1,
      post: json['post'] as int? ?? -1,
      content: json['content']?.toString() ?? '',
      user: PostUser.fromJson(json['user'] as Map<String, dynamic>),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'].toString())
          : DateTime.now(),
      parent: json['parent'] as int?,
      replies: (json['replies'] as List<dynamic>?)
          ?.map((r) => Comment.fromJson(r as Map<String, dynamic>))
          .toList() ?? const [],
      likesCount: json['likes_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      status: json['status']?.toString() ?? 'active',
    );
  }

  Map<String, dynamic> toJson() => {
    'post': post,
    'content': content,
    if (parent != null) 'parent': parent,
  };
}
