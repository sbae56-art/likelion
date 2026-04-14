import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String googleClientId =
      '885762786337-baofjqmveplr5u26k5fmltkuoeahvqct.apps.googleusercontent.com';

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

    try {
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
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_full_name', fullName);

        if (!prefs.containsKey('profile_age')) {
          await prefs.setInt('profile_age', 34);
        }
        if (!prefs.containsKey('profile_gender')) {
          await prefs.setString('profile_gender', 'Others');
        }
        if (!prefs.containsKey('profile_blood_type')) {
          await prefs.setString('profile_blood_type', 'O+');
        }
        if (!prefs.containsKey('profile_smoker')) {
          await prefs.setBool('profile_smoker', false);
        }
        if (!prefs.containsKey('profile_alcohol')) {
          await prefs.setBool('profile_alcohol', false);
        }

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
    } catch (e) {
      return {
        'success': false,
        'message': 'Signup exception: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/auth/login');

    try {
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
        return {
          'success': true,
          'data': body,
        };
      }

      return {
        'success': false,
        'message': _extractMessage(response, 'Login failed'),
        'statusCode': response.statusCode,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Login exception: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> loginWithIdToken({
    required String idToken,
    String? email,
    String? displayName,
  }) async {
    try {
      final body = <String, dynamic>{
        'id_token': idToken,
        'display_name': displayName,
      };

      if (email != null && email.trim().isNotEmpty) {
        body['email'] = email.trim();
      }

      final response = await http.post(
        Uri.parse('$baseUrl/auth/google/mobile'),
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        await _saveToken(decoded);

        if (displayName != null && displayName.trim().isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('profile_full_name', displayName.trim());
        }

        return {
          'success': true,
          'data': decoded,
        };
      }

      return {
        'success': false,
        'message': _extractMessage(response, 'Google login failed'),
        'statusCode': response.statusCode,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Google login exception: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> updateProfile({
    required String fullName,
    required int age,
    required String gender,
    required String bloodType,
    required bool smoker,
    required bool alcohol,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('profile_full_name', fullName);
    await prefs.setInt('profile_age', age);
    await prefs.setString('profile_gender', gender);
    await prefs.setString('profile_blood_type', bloodType);
    await prefs.setBool('profile_smoker', smoker);
    await prefs.setBool('profile_alcohol', alcohol);

    try {
      final token = prefs.getString('access_token');

      if (token != null && token.isNotEmpty) {
        final response = await http.patch(
          Uri.parse('$baseUrl/users/me'),
          headers: {
            'Content-Type': 'application/json',
            'accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'full_name': fullName,
            'age': age,
            'gender': gender,
            'blood_type': bloodType,
          }),
        );

        if (response.statusCode != 200) {
          return {
            'success': false,
            'message': _extractMessage(response, 'Failed to update profile'),
            'statusCode': response.statusCode,
          };
        }
      }

      return {
        'success': true,
        'message': 'Profile updated successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Profile update exception: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> getSavedProfile() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'full_name': prefs.getString('profile_full_name') ?? 'Alex Johnson',
      'age': prefs.getInt('profile_age') ?? 34,
      'gender': prefs.getString('profile_gender') ?? 'Others',
      'blood_type': prefs.getString('profile_blood_type') ?? 'O+',
      'smoker': prefs.getBool('profile_smoker') ?? false,
      'alcohol': prefs.getBool('profile_alcohol') ?? false,
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
    await prefs.remove('profile_full_name');
    await prefs.remove('profile_age');
    await prefs.remove('profile_gender');
    await prefs.remove('profile_blood_type');
    await prefs.remove('profile_smoker');
    await prefs.remove('profile_alcohol');
  }

  static Future<void> _saveToken(Map<String, dynamic> body) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', body['access_token']);
    await prefs.setString('token_type', body['token_type']);
  }

  static String _extractMessage(http.Response response, String fallback) {
    try {
      final body = jsonDecode(response.body);
      return body['detail']?.toString() ??
          body['message']?.toString() ??
          fallback;
    } catch (_) {
      return response.body.isNotEmpty ? response.body : fallback;
    }
  }
}