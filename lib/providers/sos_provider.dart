import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

class SOSProvider with ChangeNotifier {
  List<dynamic> _sosAlerts = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<dynamic> get sosAlerts => _sosAlerts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  static const String _baseUrl = 'http://192.168.1.5:8000/api/';
  final String _sosUrl = '${_baseUrl}sos/';

  Future<bool> sendSOSAlert(String description, String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get current location
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _errorMessage = 'Location permission denied';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final Map<String, dynamic> requestBody = {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'description': description,
      };

      final response = await http.post(
        Uri.parse(_sosUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
        body: json.encode(requestBody),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Request timeout - Server took too long to respond');
        },
      );

      if (response.statusCode == 201) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        _errorMessage = errorData['message'] ?? errorData['error'] ?? 'Failed to send SOS alert';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      if (e.toString().contains('timeout')) {
        _errorMessage = 'Server is taking too long to respond. Please try again.';
      } else if (e.toString().contains('SocketException')) {
        _errorMessage = 'Cannot connect to server. Please check your internet connection.';
      } else {
        _errorMessage = 'Error sending SOS alert: ${e.toString()}';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> fetchSOSAlerts(String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(_sosUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Request timeout - Server took too long to respond');
        },
      );

      if (response.statusCode == 200) {
        _sosAlerts = json.decode(response.body);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        _errorMessage = errorData['message'] ?? errorData['error'] ?? 'Failed to fetch SOS alerts';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      if (e.toString().contains('timeout')) {
        _errorMessage = 'Server is taking too long to respond. Please try again.';
      } else if (e.toString().contains('SocketException')) {
        _errorMessage = 'Cannot connect to server. Please check your internet connection.';
      } else {
        _errorMessage = 'Error fetching SOS alerts: ${e.toString()}';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
