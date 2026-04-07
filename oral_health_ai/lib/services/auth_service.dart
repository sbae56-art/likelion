import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Android emulator
  static const String baseUrl = 'http://127.0.0.1:8000';

  // iOS simulator면 보통 http://127.0.0.1:8000
  // 실제 폰이면 네 PC 로컬 IP로 바꿔야 함

  static Future<Map<String, dynamic>> signup({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final url = Uri.parse('$baseUrl/auth/signup');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'accept': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
        'full_name': fullName,
      }),
    );

    if (response.statusCode == 200) {
      return {
        'success': true,
        'data': jsonDecode(response.body),
      };
    }

    String message = 'Signup failed';
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

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/auth/login');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'accept': 'application/json',
      },
      body: {
        'username': email, // 백엔드 계약상 email이 아니라 username
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', body['access_token']);
      await prefs.setString('token_type', body['token_type']);

      return {
        'success': true,
        'data': body,
      };
    }

    String message = 'Login failed';
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

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('token_type');
  }
}