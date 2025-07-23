
import 'package:neptrek/models/comment_model.dart';

class PostLocation {
  final double? latitude;
  final double? longitude;
  final String? placeName;

  PostLocation({
    this.latitude,
    this.longitude,
    this.placeName,
  });

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'place_name': placeName,
  };

  factory PostLocation.fromJson(Map<String, dynamic> json) {
    return PostLocation(
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      placeName: json['place_name'],
    );
  }
}

class Post {
  final int id;
  final int trekId;
  final String content;
  final List<String> images;
  final PostLocation? location;
  final DateTime createdAt;
  final String? authorName;
  final String? authorImage;
  final bool isLiked;
  final int likesCount;
  final int commentsCount;
  final List<Comment> comments;

  Post({
    required this.id,
    required this.trekId,
    required this.content,
    this.images = const [],
    this.location,
    required this.createdAt,
    this.authorName,
    this.authorImage,
    this.isLiked = false,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.comments = const [],
  });

  Post copyWith({
    int? id,
    int? trekId,
    String? content,
    List<String>? images,
    PostLocation? location,
    DateTime? createdAt,
    String? authorName,
    String? authorImage,
    bool? isLiked,
    int? likesCount,
    int? commentsCount,
    List<Comment>? comments,
  }) {
    return Post(
      id: id ?? this.id,
      trekId: trekId ?? this.trekId,
      content: content ?? this.content,
      images: images ?? this.images,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      authorName: authorName ?? this.authorName,
      authorImage: authorImage ?? this.authorImage,
      isLiked: isLiked ?? this.isLiked,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      comments: comments ?? this.comments,
    );
  }

  Map<String, dynamic> toJson() => {
    'trek': trekId,
    'content': content,
    if (images.isNotEmpty) 'images': images,
    if (location != null) 'location': location!.toJson(),
  };

  factory Post.create({
    required int trekId,
    required String content,
    List<String>? images,
    PostLocation? location,
  }) {
    return Post(
      id: -1, // Temporary ID for new posts
      trekId: trekId,
      content: content,
      images: images ?? const [],
      location: location,
      createdAt: DateTime.now(),
      authorName: null, // Will be updated by server
      isLiked: false,
      likesCount: 0,
      commentsCount: 0,
    );
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as int,
      trekId: json['trek'] as int,
      content: json['content'] as String,
      images: List<String>.from(json['images'] ?? []),
      location: json['location'] != null ? PostLocation.fromJson(json['location']) : null,
      createdAt: DateTime.parse(json['created_at']),
      authorName: json['author_name'] as String?,
      authorImage: json['author_image'] as String?,
      isLiked: json['is_liked'] ?? false,
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      comments: (json['comments'] as List<dynamic>?)
          ?.map((comment) => Comment.fromJson(comment))
          .toList() ?? [],
      
    );
  }
}
