// lib/models/user_model.dart

class Profile {
  final String displayName;
  final String photoUrl;
  final String role;
  final List<String> interests;

  Profile({
    required this.displayName,
    required this.photoUrl,
    required this.role,
    required this.interests,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      displayName: json['display_name'] as String? ?? 'N/A',
      photoUrl: json['photo_url'] as String? ?? '',
      role: json['role'] as String? ?? 'user',
      interests: (json['interests'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'display_name': displayName,
      'photo_url': photoUrl,
      'role': role,
      'interests': interests,
    };
  }

  Profile copyWith({
    String? displayName,
    String? photoUrl,
    String? role,
    List<String>? interests,
  }) {
    return Profile(
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      interests: interests ?? this.interests,
    );
  }
}

class UserInfo {
  final int id;
  final String username;
  final String email;
  final Profile profile;

  UserInfo({
    required this.id,
    required this.username,
    required this.email,
    required this.profile,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    // Handle the nested user structure where there might be user.user.id
    final actualUserJson = json['user'] as Map<String, dynamic>? ?? json;
    
    return UserInfo(
      id: actualUserJson['id'] as int,
      username: actualUserJson['username'] as String,
      email: actualUserJson['email'] as String? ?? '',
      profile: Profile.fromJson(actualUserJson['profile'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'profile': profile.toJson(),
    };
  }

  UserInfo copyWith({
    int? id,
    String? username,
    String? email,
    Profile? profile,
  }) {
    return UserInfo(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      profile: profile ?? this.profile,
    );
  }
}

class AuthUser {
  final UserInfo user; // The full user object from the API
  final String displayName; // Convenience getter
  final String photoUrl; // Convenience getter  
  final List<String> interests; // Convenience getter
  final String role; // Convenience getter
  final bool isActive;
  final DateTime createdAt;

  AuthUser({
    required this.user,
    required this.displayName,
    required this.photoUrl,
    required this.interests,
    required this.role,
    required this.isActive,
    required this.createdAt,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    // Handle nested user structure from signup/login response
    final userJson = json['user'] as Map<String, dynamic>;
    
    return AuthUser(
      user: UserInfo.fromJson(userJson),
      displayName: json['display_name'] as String? ?? userJson['profile']?['display_name'] ?? 'N/A',
      photoUrl: json['photo_url'] as String? ?? userJson['profile']?['photo_url'] ?? '',
      interests: (json['interests'] as List<dynamic>?)?.map((item) => item.toString()).toList() ?? 
                (userJson['profile']?['interests'] as List<dynamic>?)?.map((item) => item.toString()).toList() ?? [],
      role: json['role'] as String? ?? userJson['profile']?['role'] ?? 'user',
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'display_name': displayName,
      'photo_url': photoUrl,
      'interests': interests,
      'role': role,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  AuthUser copyWith({
    UserInfo? user,
    String? displayName,
    String? photoUrl,
    List<String>? interests,
    String? role,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return AuthUser(
      user: user ?? this.user,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      interests: interests ?? this.interests,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class AuthResponse {
  final String token;
  final AuthUser user;
  final String? message;

  AuthResponse({
    required this.token,
    required this.user,
    this.message,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
      message: json['message'] as String?,
    );
  }
}