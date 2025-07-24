import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/tims_model.dart';
import '../utils/constants.dart';

class TimsProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  List<TimsBooking> _bookings = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<TimsBooking> get bookings => _bookings;

  final String _timsUrl = '${ApiConstants.apiUrl}/tims/';

  Future<bool> bookTims(TimsBooking booking, String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {

      final response = await http.post(
        Uri.parse(_timsUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
        body: json.encode(booking.toJson()),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Request timeout - Server took too long to respond');
        },
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        final newBooking = TimsBooking.fromJson(responseData);
        _bookings.add(newBooking);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        _errorMessage = errorData['message'] ?? errorData['error'] ?? 'Failed to book TIMS';
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
        _errorMessage = 'Error booking TIMS: ${e.toString()}';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<List<TimsBooking>> fetchUserBookings(String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(_timsUrl),
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
        final List<dynamic> responseData = json.decode(response.body);
        _bookings = responseData.map((data) => TimsBooking.fromJson(data)).toList();
        _isLoading = false;
        notifyListeners();
        return _bookings;
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        _errorMessage = errorData['message'] ?? errorData['error'] ?? 'Failed to fetch TIMS bookings';
        _isLoading = false;
        notifyListeners();
        return [];
      }
    } catch (e) {
      if (e.toString().contains('timeout')) {
        _errorMessage = 'Server is taking too long to respond. Please try again.';
      } else if (e.toString().contains('SocketException')) {
        _errorMessage = 'Cannot connect to server. Please check your internet connection.';
      } else {
        _errorMessage = 'Error fetching TIMS bookings: ${e.toString()}';
      }
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }
}
