// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../utils/constants.dart';

class AuthProvider with ChangeNotifier {
  AuthUser? _user;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;
  String? _userRole;

  AuthUser? get user => _user;
  String? get token => _token;
  String? get userRole => _userRole;
  bool get isAuthenticated => _token != null;
  bool get isAdmin => _userRole == 'admin';
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

 
  final String _signupUrl = '${ApiConstants.apiUrl}/auth/signup/';
  final String _loginUrl = '${ApiConstants.apiUrl}/auth/login/';


  AuthProvider() {
    _loadUserAndToken();
  }

  Future<void> _loadUserAndToken() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final storedToken = prefs.getString('authToken');
      final storedUserJson = prefs.getString('authUser');

      if (storedToken != null && storedUserJson != null) {
        try {
          _token = storedToken;
          _user = AuthUser.fromJson(json.decode(storedUserJson));
        } catch (e) {
          _token = null;
          _user = null;
          // Clean up corrupted data in background
          prefs.remove('authToken');
          prefs.remove('authUser');
        }
      }
    } catch (e) {
      _token = null;
      _user = null;
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveUserAndToken(String token, AuthUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);
    await prefs.setString('authUser', json.encode(user.toJson()));
  }

  // Force save current auth state (useful for ensuring data persistence)
  Future<void> forceSaveCurrentState() async {
    if (_token != null && _user != null) {
      try {
        await _saveUserAndToken(_token!, _user!);
      } catch (e) {
        // Handle error
      }
    }
  }

  Future<bool> signup(String username, String password, String displayName) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final Map<String, dynamic> requestBody = {
        'username': username,
        'display_name': displayName,
        'password': password,
      };

      final response = await http.post(
        Uri.parse(_signupUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      ).timeout(
        const Duration(seconds: 15), // Increased timeout to 15 seconds
        onTimeout: () {
          throw Exception('Request timeout - Server took too long to respond');
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final authResponse = AuthResponse.fromJson(responseData);

        _token = authResponse.token;
        _user = authResponse.user;
        
        _isLoading = false;
        notifyListeners(); // Notify immediately to trigger navigation
        
        // Save to SharedPreferences in background (don't await)
        _saveUserAndToken(_token!, _user!).then((_) {
        }).catchError((error) {
        });
        
        return true;
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        _errorMessage = errorData['message'] ?? errorData.values.first.toString();
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      if (e.toString().contains('timeout') || e.toString().contains('Request timeout')) {
        _errorMessage = 'Server is taking too long to respond. Please try again or check your network connection.';
      } else if (e.toString().contains('SocketException') || e.toString().contains('Connection refused')) {
        _errorMessage = 'Cannot connect to server. Please check if the server is running and your internet connection.';
      } else if (e.toString().contains('HandshakeException') || e.toString().contains('TlsException')) {
        _errorMessage = 'SSL/TLS connection error. Please check server configuration.';
      } else if (e.toString().contains('FormatException')) {
        _errorMessage = 'Invalid server response format. Please try again.';
      } else {
        _errorMessage = 'Network error during signup: ${e.toString()}';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final Map<String, dynamic> requestBody = {
        'username': username,
        'password': password,
      };

      final response = await http.post(
        Uri.parse(_loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      ).timeout(
        const Duration(seconds: 15), // Increased timeout to 15 seconds
        onTimeout: () {
          throw Exception('Request timeout - Server took too long to respond');
        },
      );

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> responseData = json.decode(response.body);
          
          // Check if response has expected structure
          if (!responseData.containsKey('token')) {
            _errorMessage = 'Server response missing token';
            _isLoading = false;
            notifyListeners();
            return false;
          }
          
          if (!responseData.containsKey('user')) {
            _errorMessage = 'Server response missing user data';
            _isLoading = false;
            notifyListeners();
            return false;
          }
          
          final authResponse = AuthResponse.fromJson(responseData);

          _token = authResponse.token;
          _user = authResponse.user;
          _userRole = _user?.role;
          
          _isLoading = false;
          notifyListeners(); // Notify immediately to trigger navigation
          
          // Save to SharedPreferences in background (don't await)
          _saveUserAndToken(_token!, _user!).then((_) {
          }).catchError((error) {
          });
          
          return true;
        } catch (parseError) {
          _errorMessage = 'Failed to parse server response: $parseError';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      } else {
        try {
          final Map<String, dynamic> errorData = json.decode(response.body);
          _errorMessage = errorData['message'] ?? errorData['error'] ?? errorData.values.first.toString();
        } catch (e) {
          _errorMessage = 'Login failed with status ${response.statusCode}: ${response.body}';
        }
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      if (e.toString().contains('timeout') || e.toString().contains('Request timeout')) {
        _errorMessage = 'Server is taking too long to respond. Please try again or check your network connection.';
      } else if (e.toString().contains('SocketException') || e.toString().contains('Connection refused')) {
        _errorMessage = 'Cannot connect to server. Please check if the server is running and your internet connection.';
      } else if (e.toString().contains('HandshakeException') || e.toString().contains('TlsException')) {
        _errorMessage = 'SSL/TLS connection error. Please check server configuration.';
      } else if (e.toString().contains('FormatException')) {
        _errorMessage = 'Invalid server response format. Please try again.';
      } else {
        _errorMessage = 'Network error during login: ${e.toString()}';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    await prefs.remove('authUser');
    notifyListeners();
  }

  // Validate if current token is still valid by making a simple API call
  Future<bool> validateToken() async {
    if (_token == null || _user == null) return false;
    
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.apiUrl}/users/${_user!.user.id}/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $_token',
        },
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 401) {
        // Token is invalid, clear auth state
        await logout();
        return false;
      }
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Update user profile
  Future<bool> updateProfile({String? displayName, String? photoUrl}) async {
    if (_user == null || _token == null) {
      _errorMessage = 'User not authenticated';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final String updateUrl = '${ApiConstants.apiUrl}/users/${_user!.user.id}/';
      
      final Map<String, dynamic> requestBody = {
        'display_name': displayName,
        'photo_url': photoUrl,
      }..removeWhere((key, value) => value == null);

      final response = await http.patch(
        Uri.parse(updateUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $_token',
        },
        body: json.encode(requestBody),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Request timeout - Server took too long to respond');
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final updatedAuthUser = _user!.copyWith(
          displayName: displayName ?? _user!.displayName,
          photoUrl: photoUrl ?? _user!.photoUrl,
        );
        
        _user = updatedAuthUser;
        _isLoading = false;
        notifyListeners();
        
        // Save updated user data to SharedPreferences in background
        _saveUserAndToken(_token!, _user!).then((_) {
        }).catchError((error) {
        });
        
        return true;
      } else {
        try {
          final Map<String, dynamic> errorData = json.decode(response.body);
          _errorMessage = errorData['message'] ?? errorData['error'] ?? 'Failed to update profile';
        } catch (e) {
          _errorMessage = 'Failed to update profile: HTTP ${response.statusCode}';
        }
        _isLoading = false;
        notifyListeners();
        return false;
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
        _errorMessage = 'Network error while updating profile: ${e.toString()}';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update user interests
  Future<bool> updateUserInterests(List<String> interests) async {
    if (_user == null || _token == null) {
      _errorMessage = 'User not authenticated';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final String updateUrl = '${ApiConstants.apiUrl}/users/${_user!.user.id}/';
      
      final Map<String, dynamic> requestBody = {
        'profile': {
          'interests': interests,
        }
      };
      
      final response = await http.patch(
        Uri.parse(updateUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $_token',
        },
        body: json.encode(requestBody),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Request timeout - Server took too long to respond');
        },
      );

      if (response.statusCode == 401) {
        // Token is invalid or expired
        _errorMessage = 'Your session has expired. Please login again.';
        
        // Clear invalid token and user data
        _token = null;
        _user = null;
        
        // Clear from SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('authToken');
        await prefs.remove('authUser');
        
        _isLoading = false;
        notifyListeners();
        return false;
      } else if (response.statusCode == 200) {
        try {
          json.decode(response.body);
          
          // Create updated user with new interests
          final updatedProfile = _user!.user.profile.copyWith(interests: interests);
          final updatedUserInfo = _user!.user.copyWith(profile: updatedProfile);
          final updatedAuthUser = _user!.copyWith(
            user: updatedUserInfo,
            interests: interests,
          );
          
          _user = updatedAuthUser;
          
          _isLoading = false;
          notifyListeners();
          
          // Save updated user data to SharedPreferences in background
          _saveUserAndToken(_token!, _user!).then((_) {
          }).catchError((error) {
          });
          
          return true;
        } catch (parseError) {
          // Even if parsing fails, the server update was successful
          // Just update the interests locally
          final updatedProfile = _user!.user.profile.copyWith(interests: interests);
          final updatedUserInfo = _user!.user.copyWith(profile: updatedProfile);
          final updatedAuthUser = _user!.copyWith(
            user: updatedUserInfo,
            interests: interests,
          );
          
          _user = updatedAuthUser;
          _isLoading = false;
          notifyListeners();
          return true;
        }
      } else {
        try {
          final Map<String, dynamic> errorData = json.decode(response.body);
          _errorMessage = errorData['message'] ?? errorData['error'] ?? 'Failed to update interests';
        } catch (e) {
          _errorMessage = 'Failed to update interests: HTTP ${response.statusCode}';
        }
        _isLoading = false;
        notifyListeners();
        return false;
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
        _errorMessage = 'Network error while updating interests: ${e.toString()}';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Check if user has set interests (for showing interests screen on first login)
  bool get hasSetInterests => _user?.interests.isNotEmpty ?? false;

  Future<bool> addToFavorites(String trekId) async {
    if (_user == null || _token == null) {
      _errorMessage = 'User not authenticated';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final String favoritesUrl = '${ApiConstants.apiUrl}/favorites/';

      final Map<String, dynamic> requestBody = {
        'user_id': _user!.user.id,
        'trek_id': trekId,
      };

      final response = await http.post(
        Uri.parse(favoritesUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $_token',
        },
        body: json.encode(requestBody),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Request timeout - Server took too long to respond');
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        try {
          final Map<String, dynamic> errorData = json.decode(response.body);
          _errorMessage = errorData['message'] ?? errorData['error'] ?? 'Failed to add to favorites';
        } catch (e) {
          _errorMessage = 'Failed to add to favorites: HTTP ${response.statusCode}';
        }
        _isLoading = false;
        notifyListeners();
        return false;
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
        _errorMessage = 'Network error while adding to favorites: ${e.toString()}';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}