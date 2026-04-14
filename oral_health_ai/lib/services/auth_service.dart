import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String googleClientId =
      '360152998799-iud4ufqjuqb5ak9jjl44dl4pm8iki0je.apps.googleusercontent.com';

  static final GoogleSignIn googleSignIn = GoogleSignIn.instance;
  static Future<void>? _googleInitialization;

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

  static Future<void> initializeGoogleSignIn() {
    return _googleInitialization ??= googleSignIn.initialize(
      clientId: googleClientId,
    );
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

  static Future<Map<String, dynamic>> loginWithGoogle() async {
    try {
      await initializeGoogleSignIn();

      if (!googleSignIn.supportsAuthenticate()) {
        return {
          'success': false,
          'message': 'Google login on web uses the Google-provided button.',
        };
      }

      final GoogleSignInAccount user = await googleSignIn.authenticate();
      return loginWithGoogleAccount(user);
    } on GoogleSignInException catch (error) {
      return {
        'success': false,
        'message': _googleSignInErrorMessage(error),
      };
    } catch (error) {
      return {
        'success': false,
        'message': 'Google login failed: $error',
      };
    }
  }

  static Future<Map<String, dynamic>> loginWithGoogleAccount(
    GoogleSignInAccount user,
  ) async {
    final String? idToken = user.authentication.idToken;
    if (idToken == null || idToken.isEmpty) {
      return {
        'success': false,
        'message': 'Google ID token was not returned.',
      };
    }

    final response = await http.post(
      Uri.parse('$baseUrl/auth/google/mobile'),
      headers: {
        'Content-Type': 'application/json',
        'accept': 'application/json',
      },
      body: jsonEncode({
        'id_token': idToken,
        'email': user.email,
        'display_name': user.displayName,
      }),
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

    String message = 'Google login failed';
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

  static String _googleSignInErrorMessage(GoogleSignInException error) {
    switch (error.code) {
      case GoogleSignInExceptionCode.canceled:
        return 'Google sign-in was canceled.';
      default:
        return error.description ?? 'Google sign-in failed.';
    }
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('token_type');

    try {
      await googleSignIn.signOut();
    } catch (_) {
      // Ignore Google sign-out failures so local logout still succeeds.
    }
  }
}