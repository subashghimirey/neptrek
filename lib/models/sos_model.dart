class EmergencyContact {
  final String name;
  final String email;
  final String type;
  final String source;

  EmergencyContact({
    required this.name,
    required this.email,
    required this.type,
    required this.source,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      type: json['type'] ?? '',
      source: json['source'] ?? '',
    );
  }
}

class SOSAlert {
  final String id;
  final String userId;
  final String alertType;
  final String location;
  final String description;
  final double latitude;
  final double longitude;
  final double altitude;
  final bool isResolved;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  SOSAlert({
    required this.id,
    required this.userId,
    required this.alertType,
    required this.location,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.isResolved,
    required this.createdAt,
    this.resolvedAt,
  });

  factory SOSAlert.fromJson(Map<String, dynamic> json) {
    return SOSAlert(
      id: json['id'].toString(),
      userId: json['userId'].toString(),
      alertType: json['alertType'],
      location: json['location'],
      description: json['description'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      altitude: json['altitude'].toDouble(),
      isResolved: json['isResolved'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      resolvedAt: json['resolvedAt'] != null 
          ? DateTime.parse(json['resolvedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'alertType': alertType,
      'location': location,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'isResolved': isResolved,
      'createdAt': createdAt.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
    };
  }
}
