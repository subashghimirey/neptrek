class UserInfoMini {
  final int id;
  final String displayName;
  final String photoUrl;

  const UserInfoMini({
    required this.id,
    required this.displayName,
    required this.photoUrl,
  });

  factory UserInfoMini.fromJson(Map<String, dynamic> json) {
    return UserInfoMini(
      id: json['id'] as int? ?? -1,
      displayName: json['display_name'] as String? ?? 'Unknown',
      photoUrl: json['photo_url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'display_name': displayName,
      'photo_url': photoUrl,
    };
  }
}
