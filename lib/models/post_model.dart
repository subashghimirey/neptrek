
import 'package:neptrek/models/comment_model.dart';

class PostUser {
  final int id;
  final String displayName;
  final String photoUrl;

  const PostUser({
    required this.id,
    required this.displayName,
    required this.photoUrl,
  });

  factory PostUser.fromJson(Map<String, dynamic> json) {
    return PostUser(
      id: json['id'] is String ? int.parse(json['id']) : (json['id'] as int? ?? -1),
      displayName: json['display_name'] as String? ?? 'Unknown',
      photoUrl: json['photo_url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'display_name': displayName,
    'photo_url': photoUrl,
  };
}

class TrekInfo {
  final int id;
  final String name;

  const TrekInfo({
    required this.id,
    required this.name,
  });

  factory TrekInfo.fromJson(Map<String, dynamic> json) {
    return TrekInfo(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };
}

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
      latitude: json['latitude'] is String 
          ? double.tryParse(json['latitude']) 
          : (json['latitude'] as num?)?.toDouble(),
      longitude: json['longitude'] is String 
          ? double.tryParse(json['longitude']) 
          : (json['longitude'] as num?)?.toDouble(),
      placeName: json['place_name'] as String?,
    );
  }
}

class Post {
  final int id;
  final int trek;
  final String trekName;
  final PostUser user;
  final String content;
  final List<String> images;
  final PostLocation? location;
  final int likesCount;
  final int commentsCount;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Comment> comments;
  final bool isLiked;

  const Post({
    required this.id,
    required this.trek,
    required this.trekName,
    required this.user,
    required this.content,
    required this.images,
    this.location,
    required this.likesCount,
    required this.commentsCount,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.comments,
    required this.isLiked,
  });

  factory Post.create({
    required int trekId,
    required String content,
    required List<String> images,
  }) => Post(
    id: -1,
    trek: trekId,
    trekName: '',
    content: content,
    images: images,
    user: PostUser(id: -1, displayName: '', photoUrl: ''),
    likesCount: 0,
    commentsCount: 0,
    status: 'active',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    comments: const [],
    isLiked: false,
  );

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] is String ? int.parse(json['id']) : (json['id'] as int? ?? -1),
      trek: json['trek'] is String ? int.parse(json['trek']) : (json['trek'] as int? ?? -1),
      trekName: json['trek_name'] as String? ?? '',
      user: json['user'] is Map<String, dynamic> 
          ? PostUser.fromJson(json['user'] as Map<String, dynamic>)
          : PostUser(id: -1, displayName: 'Unknown', photoUrl: ''),
      content: json['content'] as String? ?? '',
      images: (json['images'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      location: json['location'] is Map<String, dynamic>
          ? PostLocation.fromJson(json['location'] as Map<String, dynamic>)
          : null,
      likesCount: json['likes_count'] is String 
          ? int.parse(json['likes_count']) 
          : (json['likes_count'] as int? ?? 0),
      commentsCount: json['comments_count'] is String 
          ? int.parse(json['comments_count']) 
          : (json['comments_count'] as int? ?? 0),
      status: json['status'] as String? ?? 'active',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'].toString()) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'].toString()) 
          : DateTime.now(),
      comments: (json['comments'] as List<dynamic>?)
          ?.where((e) => e is Map<String, dynamic>)
          .map((e) => Comment.fromJson(e as Map<String, dynamic>))
          .toList() ?? const [],
      isLiked: json['is_liked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'trek': trek,
    'content': content,
    'images': images,
  };

  Post copyWith({
    int? id,
    int? trek,
    String? trekName,
    PostUser? user,
    String? content,
    List<String>? images,
    PostLocation? location,
    int? likesCount,
    int? commentsCount,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Comment>? comments,
    bool? isLiked,
  }) => Post(
    id: id ?? this.id,
    trek: trek ?? this.trek,
    trekName: trekName ?? this.trekName,
    user: user ?? this.user,
    content: content ?? this.content,
    images: images ?? this.images,
    location: location ?? this.location,
    likesCount: likesCount ?? this.likesCount,
    commentsCount: commentsCount ?? this.commentsCount,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    comments: comments ?? this.comments,
    isLiked: isLiked ?? this.isLiked,
  );
}
