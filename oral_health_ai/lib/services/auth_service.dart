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
        await refreshProfileFromServer();
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
        await refreshProfileFromServer();

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
            'smoker': smoker,
            'alcohol': alcohol,
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

  static Future<void> refreshProfileFromServer() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null || token.isEmpty) return;

    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/users/me'),
            headers: {
              'accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) return;

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) return;

      final fn = decoded['full_name']?.toString();
      if (fn != null && fn.isNotEmpty) {
        await prefs.setString('profile_full_name', fn);
      }

      final ageVal = decoded['age'];
      if (ageVal is int) {
        await prefs.setInt('profile_age', ageVal);
      } else if (ageVal != null) {
        final p = int.tryParse(ageVal.toString());
        if (p != null) await prefs.setInt('profile_age', p);
      }

      final g = decoded['gender']?.toString();
      if (g != null && g.isNotEmpty) {
        await prefs.setString('profile_gender', g);
      }

      final bt = decoded['blood_type']?.toString();
      if (bt != null && bt.isNotEmpty) {
        await prefs.setString('profile_blood_type', bt);
      }

      final sm = decoded['smoker'];
      if (sm is bool) {
        await prefs.setBool('profile_smoker', sm);
      } else if (sm != null) {
        await prefs.setBool('profile_smoker', sm.toString() == 'true');
      }

      final alc = decoded['alcohol'];
      if (alc is bool) {
        await prefs.setBool('profile_alcohol', alc);
      } else if (alc != null) {
        await prefs.setBool('profile_alcohol', alc.toString() == 'true');
      }
    } catch (_) {}
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