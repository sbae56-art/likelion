import 'dart:convert';
import 'package:cross_file/cross_file.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ScanService {
  static String get baseUrl => AuthService.baseUrl;

  static Future<Map<String, dynamic>> analyzeImage(XFile imageFile) async {
    final token = await AuthService.getToken();

    if (token == null || token.isEmpty) {
      return {
        'success': false,
        'message': 'No access token found',
      };
    }

    final url = Uri.parse('$baseUrl/scans/predict');

    try {
      final bytes = await imageFile.readAsBytes();

      final request = http.MultipartRequest('POST', url)
        ..headers['accept'] = 'application/json'
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(
          http.MultipartFile.fromBytes(
            'image',
            bytes,
            filename:
                imageFile.name.isNotEmpty ? imageFile.name : 'scan.jpg',
          ),
        );

      final streamedResponse =
          await request.send().timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        String message = 'Failed to analyze scan';
        try {
          final body = jsonDecode(response.body);
          if (body is Map<String, dynamic>) {
            message = body['detail']?.toString() ??
                body['message']?.toString() ??
                message;
          }
        } catch (_) {
          if (response.body.isNotEmpty) {
            message = response.body;
          }
        }

        return {
          'success': false,
          'message': message,
          'statusCode': response.statusCode,
        };
      }

      final decoded =
          response.body.isNotEmpty ? jsonDecode(response.body) : null;

      if (decoded is! Map<String, dynamic>) {
        return {
          'success': false,
          'message': 'Unrecognized scan response format',
        };
      }

      final rawProb = decoded['prob_percent'];
      final rawLevel = decoded['level'];

      if (rawProb == null || rawLevel == null) {
        return {
          'success': false,
          'message': 'Unrecognized scan response format',
        };
      }

      int riskPercent;
      if (rawProb is num) {
        riskPercent = rawProb.round().clamp(0, 100);
      } else {
        final parsed = double.tryParse(rawProb.toString());
        if (parsed == null) {
          return {
            'success': false,
            'message': 'Invalid probability format from server',
          };
        }
        riskPercent = parsed.round().clamp(0, 100);
      }

      final level = rawLevel.toString().toLowerCase().trim();

      String riskType;
      if (level == 'risk') {
        riskType = 'highRisk';
      } else if (level == 'caution') {
        riskType = 'caution';
      } else if (level == 'normal') {
        riskType = 'normal';
      } else {
        return {
          'success': false,
          'message': 'Unknown risk level from server: $rawLevel',
        };
      }

      return {
        'success': true,
        'riskPercent': riskPercent,
        'riskType': riskType,
        'message': decoded['summary']?.toString() ?? '',
        'details': decoded['details'],
        'recommendations': decoded['recommendations'],
        'raw': decoded,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Scan exception: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> getHistory() async {
    final token = await AuthService.getToken();

    if (token == null || token.isEmpty) {
      return {
        'success': false,
        'message': 'No access token found',
      };
    }

    final url = Uri.parse('$baseUrl/scans/history');

    try {
      final response = await http.get(
        url,
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 20));

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
    } catch (e) {
      return {
        'success': false,
        'message': 'History exception: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> getScanDetail(int scanId) async {
    final token = await AuthService.getToken();

    if (token == null || token.isEmpty) {
      return {
        'success': false,
        'message': 'No access token found',
      };
    }

    final url = Uri.parse('$baseUrl/scans/detail/$scanId');

    try {
      final response = await http.get(
        url,
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      }

      String message = 'Failed to load detail';
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
    } catch (e) {
      return {
        'success': false,
        'message': 'Detail exception: $e',
      };
    }
  }
}