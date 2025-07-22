// lib/providers/trek_provider.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/trek_model.dart';

class TrekProvider with ChangeNotifier {
  List<Trek> _treks = [];
  List<Trek> _recommendedTreks = [];
  Trek? _selectedTrek;
  bool _isLoading = false;
  bool _isLoadingRecommended = false;
  bool _isLoadingDetails = false;
  String? _errorMessage;
  String? _recommendedErrorMessage;
  String? _detailsErrorMessage;
  // Map to store trek ID to favorite ID mapping
  Map<String, String> _favoriteIds = {};
  Set<String> get favoriteTrekIds => _favoriteIds.keys.toSet();

  List<Trek> get treks => _treks;
  List<Trek> get recommendedTreks => _recommendedTreks;
  Trek? get selectedTrek => _selectedTrek;
  bool get isLoading => _isLoading;
  bool get isLoadingRecommended => _isLoadingRecommended;
  bool get isLoadingDetails => _isLoadingDetails;
  String? get errorMessage => _errorMessage;
  String? get recommendedErrorMessage => _recommendedErrorMessage;
  String? get detailsErrorMessage => _detailsErrorMessage;
  List<String> get favoriteIds => _favoriteIds.keys.toList();

  static const String _baseUrl = 'http://192.168.1.3:8000/api/';
  final String _treksUrl = '${_baseUrl}treks/';
  final String _recommendationsUrl = '${_baseUrl}recommendations/';
  final String _favoritesUrl = '${_baseUrl}favorites/';

  // Toggle trek favorite status
  Future<void> toggleFavorite(String trekId, String? authToken, {String? userId}) async {
    if (authToken == null || userId == null) {
      return;
    }

    try {
      if (_favoriteIds.containsKey(trekId)) {
        // Remove from favorites using the stored favorite ID
        final String favoriteId = _favoriteIds[trekId]!;
        final String deleteFavoriteUrl = '${_baseUrl}favorites/$favoriteId/';
        
        final response = await http.delete(
          Uri.parse(deleteFavoriteUrl),
          headers: {
            'Authorization': 'Token $authToken',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 204 || response.statusCode == 200) {
          _favoriteIds.remove(trekId);
          notifyListeners();
        }
      } else {
        // Add to favorites
        final trekNum = int.parse(trekId);
        final data = {
          'trek_id': trekNum
        };
        final jsonData = json.encode(data);
        
        final response = await http.post(
          Uri.parse(_favoritesUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Token $authToken',
          },
          body: jsonData,
        );

        if (response.statusCode == 201 || response.statusCode == 200) {
          final responseData = json.decode(response.body);
          final String favoriteId = responseData['id'].toString();
          _favoriteIds[trekId.toString()] = favoriteId;
          notifyListeners();
        }
      }
    } catch (e) {
      // Error handled silently
    }
  }

  // Check if trek is favorite
  bool isFavorite(String trekId) => _favoriteIds.containsKey(trekId);

  // Fetch all treks
  Future<void> fetchTreks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(_treksUrl),
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Request timeout - Server took too long to respond');
        },
      );

      if (response.statusCode == 200) {
        try {
          final List<dynamic> treksData = json.decode(response.body);
          _treks = treksData.map((trekJson) => Trek.fromJson(trekJson)).toList();
          _errorMessage = null;
        } catch (parseError) {
          _errorMessage = 'Failed to parse treks data: $parseError';
          _treks = [];
        }
      } else {
        try {
          final Map<String, dynamic> errorData = json.decode(response.body);
          _errorMessage = errorData['message'] ?? errorData['error'] ?? 'Failed to fetch treks';
        } catch (e) {
          _errorMessage = 'Failed to fetch treks: HTTP ${response.statusCode}';
        }
        _treks = [];
      }
    } catch (e) {
      if (e.toString().contains('timeout') || e.toString().contains('Request timeout')) {
        _errorMessage = 'Server is taking too long to respond. Please check your network connection.';
      } else if (e.toString().contains('SocketException') || e.toString().contains('Connection refused')) {
        _errorMessage = 'Cannot connect to server. Please check if the server is running and your internet connection.';
      } else if (e.toString().contains('HandshakeException') || e.toString().contains('TlsException')) {
        _errorMessage = 'SSL/TLS connection error. Please check server configuration.';
      } else if (e.toString().contains('FormatException')) {
        _errorMessage = 'Invalid server response format. Please try again.';
      } else {
        _errorMessage = 'Network error while fetching treks: ${e.toString()}';
      }
      _treks = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // Fetch recommended treks based on user interests
  Future<void> fetchRecommendedTreks(String? authToken) async {
    _isLoadingRecommended = true;
    _recommendedErrorMessage = null;
    notifyListeners();

    try {
      if (authToken == null) {
        // Fallback to first few treks if no authentication
        if (_treks.isNotEmpty) {
          _recommendedTreks = _treks.take(3).toList();
        } else {
          _recommendedTreks = [];
        }
        _isLoadingRecommended = false;
        notifyListeners();
        return;
      }
      
      final response = await http.get(
        Uri.parse(_recommendationsUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $authToken',
        },
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Request timeout - Server took too long to respond');
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        _recommendedTreks = jsonData.map((trekJson) => Trek.fromJson(trekJson)).toList();
        _recommendedErrorMessage = null;
      } else if (response.statusCode == 401) {
        _recommendedErrorMessage = 'Authentication required for personalized recommendations';
        // Fallback to general treks
        if (_treks.isNotEmpty) {
          _recommendedTreks = _treks.take(3).toList();
        } else {
          _recommendedTreks = [];
        }
      } else {
        _recommendedErrorMessage = 'Failed to fetch personalized recommendations';
        // Fallback to general treks
        if (_treks.isNotEmpty) {
          _recommendedTreks = _treks.take(3).toList();
        } else {
          _recommendedTreks = [];
        }
      }
    } catch (e) {
      if (e.toString().contains('timeout') || e.toString().contains('Request timeout')) {
        _recommendedErrorMessage = 'Server is taking too long to respond for recommendations';
      } else if (e.toString().contains('SocketException') || e.toString().contains('Connection refused')) {
        _recommendedErrorMessage = 'Cannot connect to server for recommendations';
      } else {
        _recommendedErrorMessage = 'Network error while fetching recommendations: ${e.toString()}';
      }
      
      // Fallback to general treks on error
      if (_treks.isNotEmpty) {
        _recommendedTreks = _treks.take(3).toList();
      } else {
        _recommendedTreks = [];
      }
    }

    _isLoadingRecommended = false;
    notifyListeners();
  }

  // Get trek by ID
  Trek? getTrekById(int id) {
    try {
      return _treks.firstWhere((trek) => trek.id == id);
    } catch (e) {
      return null;
    }
  }

  // Refresh all data
  Future<void> refreshData(String? authToken) async {
    await fetchTreks();
    await fetchRecommendedTreks(authToken);
  }

  // Fetch trek details by ID
  Future<Trek?> fetchTrekDetails(int trekId) async {
    _isLoadingDetails = true;
    _detailsErrorMessage = null;
    _selectedTrek = null;
    notifyListeners();

    try {
      final String trekDetailUrl = '${_baseUrl}treks/$trekId/';
      
      final response = await http.get(
        Uri.parse(trekDetailUrl),
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Request timeout - Server took too long to respond');
        },
      );

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> trekData = json.decode(response.body);
          _selectedTrek = Trek.fromJson(trekData);
          
          _detailsErrorMessage = null;
          _isLoadingDetails = false;
          notifyListeners();
          return _selectedTrek;
        } catch (parseError) {
          _detailsErrorMessage = 'Failed to parse trek details: $parseError';
          _selectedTrek = null;
        }
      } else {
        try {
          final Map<String, dynamic> errorData = json.decode(response.body);
          _detailsErrorMessage = errorData['message'] ?? errorData['error'] ?? 'Failed to fetch trek details';
        } catch (e) {
          _detailsErrorMessage = 'Failed to fetch trek details: HTTP ${response.statusCode}';
        }
        _selectedTrek = null;
      }
    } catch (e) {
      if (e.toString().contains('timeout') || e.toString().contains('Request timeout')) {
        _detailsErrorMessage = 'Server is taking too long to respond. Please check your network connection.';
      } else if (e.toString().contains('SocketException') || e.toString().contains('Connection refused')) {
        _detailsErrorMessage = 'Cannot connect to server. Please check if the server is running and your internet connection.';
      } else if (e.toString().contains('HandshakeException') || e.toString().contains('TlsException')) {
        _detailsErrorMessage = 'SSL/TLS connection error. Please check server configuration.';
      } else if (e.toString().contains('FormatException')) {
        _detailsErrorMessage = 'Invalid server response format. Please try again.';
      } else {
        _detailsErrorMessage = 'Network error while fetching trek details: ${e.toString()}';
      }
      _selectedTrek = null;
    }

    _isLoadingDetails = false;
    notifyListeners();
    return null;
  }

  // Add trek to favorites
  Future<void> addToFavorites(int trekId, String authToken, {required String userId}) async {
    final String favoritesUrl = '${_baseUrl}favorites/';

    try {
      final data = {'trek_id': trekId};
      
      final response = await http.post(
        Uri.parse(favoritesUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $authToken',
        },
        body: json.encode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        final String favoriteId = responseData['id'].toString();
        _favoriteIds[trekId.toString()] = favoriteId;
        notifyListeners();
      }
    } catch (e) {
      // Error handled silently
    }
  }

  // Fetch user's favorite treks
  Future<void> fetchFavorites(String? authToken) async {
    if (authToken == null) {
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(_favoritesUrl),
        headers: {
          'Authorization': 'Token $authToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> favoritesData = json.decode(response.body);
        
        // Clear existing favorites
        _favoriteIds.clear();
        
        // Store both trek ID and favorite ID
        for (var favorite in favoritesData) {
          final String trekId = favorite['trek']['id'].toString();
          final String favoriteId = favorite['id'].toString();
          _favoriteIds[trekId] = favoriteId;
        }
        
        notifyListeners();
      }
    } catch (e) {
      // Error handled silently
    }
  }

  // Clear all data
  void clearData() {
    _treks = [];
    _recommendedTreks = [];
    _selectedTrek = null;
    _errorMessage = null;
    _recommendedErrorMessage = null;
    _detailsErrorMessage = null;
    _favoriteIds.clear();
    _isLoading = false;
    _isLoadingRecommended = false;
    _isLoadingDetails = false;
    notifyListeners();
  }
}
