// lib/models/trek_model.dart
import 'dart:convert';

class Trek {
  final int id;
  final String name;
  final String district;
  final String region;
  final String difficulty;
  final String duration;
  final List<String> bestSeasons;
  final ElevationProfile elevationProfile;
  final String description;
  final String? historicalSignificance;
  final List<String> itinerary;
  final CostBreakdown costBreakdown;
  final String transportation;
  final List<String> nearbyAttractions;
  final List<String> requiredPermits;
  final List<String> recommendedGear;
  final SafetyInfo safetyInfo;
  final List<String> photos;
  final List<ItineraryPoint> itineraryPoints;
  final double? transitCardCost;
  final double? latitude;
  final double? longitude;
  final String? clusterLabel;
  final List<String>? tags;

  Trek({
    required this.id,
    required this.name,
    required this.district,
    required this.region,
    required this.difficulty,
    required this.duration,
    required this.bestSeasons,
    required this.elevationProfile,
    required this.description,
    this.historicalSignificance,
    required this.itinerary,
    required this.costBreakdown,
    required this.transportation,
    required this.nearbyAttractions,
    required this.requiredPermits,
    required this.recommendedGear,
    required this.safetyInfo,
    required this.photos,
    required this.itineraryPoints,
    this.transitCardCost,
    this.latitude,
    this.longitude,
    this.clusterLabel,
    this.tags,
  });

  factory Trek.fromJson(Map<String, dynamic> json) {
    return Trek(
      id: json['id'] as int,
      name: json['name'] as String,
      district: json['district'] as String,
      region: json['region'] as String,
      difficulty: json['difficulty'] as String,
      duration: json['duration'] as String,
      bestSeasons: List<String>.from(json['best_seasons'] ?? []),
      elevationProfile: ElevationProfile.fromJson(json['elevation_profile'] ?? {}),
      description: json['description'] as String,
      historicalSignificance: json['historical_significance'] as String?,
      itinerary: List<String>.from(json['itinerary'] ?? []),
      costBreakdown: CostBreakdown.fromJson(json['cost_breakdown'] ?? {}),
      transportation: json['transportation'] as String? ?? '',
      nearbyAttractions: List<String>.from(json['nearby_attractions'] ?? []),
      requiredPermits: List<String>.from(json['required_permits'] ?? []),
      recommendedGear: List<String>.from(json['recommended_gear'] ?? []),
      safetyInfo: SafetyInfo.fromJson(json['safety_info'] ?? {}),
      photos: List<String>.from(json['photos'] ?? []),
      itineraryPoints: (json['itinerary_points'] as List<dynamic>?)
          ?.map((point) => ItineraryPoint.fromJson(point))
          .toList() ?? [],
      transitCardCost: json['transit_card_cost']?.toDouble(),
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      clusterLabel: json['cluster_label'] as String?,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'district': district,
      'region': region,
      'difficulty': difficulty,
      'duration': duration,
      'best_seasons': bestSeasons,
      'elevation_profile': elevationProfile.toJson(),
      'description': description,
      'historical_significance': historicalSignificance,
      'itinerary': itinerary,
      'cost_breakdown': costBreakdown.toJson(),
      'transportation': transportation,
      'nearby_attractions': nearbyAttractions,
      'required_permits': requiredPermits,
      'recommended_gear': recommendedGear,
      'safety_info': safetyInfo.toJson(),
      'photos': photos,
      'itinerary_points': itineraryPoints.map((point) => point.toJson()).toList(),
      'transit_card_cost': transitCardCost,
      'latitude': latitude,
      'longitude': longitude,
      'cluster_label': clusterLabel,
      'tags': tags,
    };
  }
}

class ElevationProfile {
  final String maxElevation;
  final String minElevation;

  ElevationProfile({
    required this.maxElevation,
    required this.minElevation,
  });

  factory ElevationProfile.fromJson(Map<String, dynamic> json) {
    return ElevationProfile(
      maxElevation: json['max_elevation'] as String? ?? '',
      minElevation: json['min_elevation'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'max_elevation': maxElevation,
      'min_elevation': minElevation,
    };
  }
}

class CostBreakdown {
  final String permits;
  final String guide;
  final String porter;
  final String accommodation;
  final String food;

  CostBreakdown({
    required this.permits,
    required this.guide,
    required this.porter,
    required this.accommodation,
    required this.food,
  });

  factory CostBreakdown.fromJson(Map<String, dynamic> json) {
    return CostBreakdown(
      permits: json['permits'] as String? ?? '',
      guide: json['guide'] as String? ?? '',
      porter: json['porter'] as String? ?? '',
      accommodation: json['accommodation'] as String? ?? '',
      food: json['food'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'permits': permits,
      'guide': guide,
      'porter': porter,
      'accommodation': accommodation,
      'food': food,
    };
  }
}

class SafetyInfo {
  final String? altitudeSicknessRisk;

  SafetyInfo({this.altitudeSicknessRisk});

  factory SafetyInfo.fromJson(Map<String, dynamic> json) {
    return SafetyInfo(
      altitudeSicknessRisk: json['altitude_sickness_risk'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'altitude_sickness_risk': altitudeSicknessRisk,
    };
  }
}

class ItineraryPoint {
  final String name;
  final double lat;
  final double lng;

  ItineraryPoint({
    required this.name,
    required this.lat,
    required this.lng,
  });

  factory ItineraryPoint.fromJson(Map<String, dynamic> json) {
    return ItineraryPoint(
      name: json['name'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'lat': lat,
      'lng': lng,
    };
  }
}
