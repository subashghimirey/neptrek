import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:neptrek/models/sos_model.dart';
import 'package:neptrek/utils/constants.dart';

class SOSService {
  static Future<List<SOSAlert>> getMyAlerts({String? authToken}) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/api/sos/my-alerts/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': authToken != null ? 'Token $authToken' : '',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => SOSAlert.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load alerts');
    }
  }

  static Future<SOSAlert> getAlertDetails(int alertId, {String? authToken}) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/api/sos/$alertId/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': authToken != null ? 'Token $authToken' : '',
      },
    );

    if (response.statusCode == 200) {
      return SOSAlert.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load alert details');
    }
  }
}
