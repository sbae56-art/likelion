import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ScanService {
  static const String baseUrl = AuthService.baseUrl;

  static Future<Map<String, dynamic>> getHistory() async {
    final token = await AuthService.getToken();

    if (token == null || token.isEmpty) {
      return {
        'success': false,
        'message': 'No access token found',
      };
    }

    final url = Uri.parse('$baseUrl/scans/history');

    final response = await http.get(
      url,
      headers: {
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return {
        'success': true,
        'data': jsonDecode(response.body),
      };
    }

    String message = 'Failed to load history';
    try {
      final body = jsonDecode(response.body);
      message = body['detail']?.toString() ?? message;
    } catch (_) {
      message = response.body.isNotEmpty ? response.body : message;
    }

    return {
      'success': false,
      'message': message,
      'statusCode': response.statusCode,
    };
  }
}