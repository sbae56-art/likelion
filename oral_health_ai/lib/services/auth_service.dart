import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String googleClientId =
      '360152998799-iud4ufqjuqb5ak9jjl44dl4pm8iki0je.apps.googleusercontent.com';

  static String get baseUrl {
    if (kIsWeb) {
      return 'https://jyun45-oraq-backend.hf.space';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8000';
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return 'http://127.0.0.1:8000';
      case TargetPlatform.fuchsia:
        return 'http://127.0.0.1:8000';
    }
  }

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

    return {
      'success': false,
      'message': _extractMessage(response, 'Signup failed'),
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
        'Content-Type': 'application/json',
        'accept': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      await _saveToken(body);
      return {'success': true, 'data': body};
    }

    return {
      'success': false,
      'message': _extractMessage(response, 'Login failed'),
      'statusCode': response.statusCode,
    };
  }

  static Future<Map<String, dynamic>> loginWithIdToken({
    required String idToken,
    required String email,
    String? displayName,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/google/mobile'),
      headers: {
        'Content-Type': 'application/json',
        'accept': 'application/json',
      },
      body: jsonEncode({
        'id_token': idToken,
        'email': email,
        'display_name': displayName,
      }),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      await _saveToken(body);
      return {'success': true, 'data': body};
    }

    return {
      'success': false,
      'message': _extractMessage(response, 'Google login failed'),
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

  static Future<void> _saveToken(Map<String, dynamic> body) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', body['access_token']);
    await prefs.setString('token_type', body['token_type']);
  }

  static String _extractMessage(http.Response response, String fallback) {
    try {
      final body = jsonDecode(response.body);
      return body['detail']?.toString() ?? fallback;
    } catch (_) {
      return response.body.isNotEmpty ? response.body : fallback;
    }
  }
}
