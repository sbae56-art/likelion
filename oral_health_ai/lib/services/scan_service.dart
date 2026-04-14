import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'auth_service.dart';

class ScanService {
  static String get baseUrl => AuthService.baseUrl;

  static Future<Map<String, String>> _authorizedHeaders() async {
    final token = await AuthService.getToken();

    if (token == null || token.isEmpty) {
      throw const _AuthException('No access token found');
    }

    return {
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static String _extractMessage(http.Response response, String fallback) {
    try {
      final body = jsonDecode(response.body);
      return body['detail']?.toString() ?? fallback;
    } catch (_) {
      return response.body.isNotEmpty ? response.body : fallback;
    }
  }

  static Future<Map<String, dynamic>> getHistory() async {
    Map<String, String> headers;
    try {
      headers = await _authorizedHeaders();
    } on _AuthException catch (error) {
      return {
        'success': false,
        'message': error.message,
      };
    }

    final url = Uri.parse('$baseUrl/scans/history');

    final response = await http.get(
      url,
      headers: headers,
    );

    if (response.statusCode == 200) {
      return {
        'success': true,
        'data': jsonDecode(response.body),
      };
    }

    return {
      'success': false,
      'message': _extractMessage(response, 'Failed to load history'),
      'statusCode': response.statusCode,
    };
  }

  static Future<Map<String, dynamic>> predictRisk(XFile imageFile) async {
    Map<String, String> headers;
    try {
      headers = await _authorizedHeaders();
    } on _AuthException catch (error) {
      return {
        'success': false,
        'message': error.message,
      };
    }

    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/scans/predict'));
    request.headers.addAll(headers);
    final imageBytes = await imageFile.readAsBytes();
    request.files.add(
      http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: imageFile.name.isEmpty ? 'scan.jpg' : imageFile.name,
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return {
        'success': true,
        'data': jsonDecode(response.body),
      };
    }

    return {
      'success': false,
      'message': _extractMessage(response, 'Failed to analyze scan'),
      'statusCode': response.statusCode,
    };
  }

  static Future<Map<String, dynamic>> getScanDetail(int scanId) async {
    Map<String, String> headers;
    try {
      headers = await _authorizedHeaders();
    } on _AuthException catch (error) {
      return {
        'success': false,
        'message': error.message,
      };
    }

    final response = await http.get(
      Uri.parse('$baseUrl/scans/detail/$scanId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return {
        'success': true,
        'data': jsonDecode(response.body),
      };
    }

    return {
      'success': false,
      'message': _extractMessage(response, 'Failed to load scan detail'),
      'statusCode': response.statusCode,
    };
  }
}

class _AuthException implements Exception {
  final String message;

  const _AuthException(this.message);
}