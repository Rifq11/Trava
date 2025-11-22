import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_config.dart';
import '../utils/storage_service.dart';

class ApiService {
  static Future<Map<String, String>> _getHeaders({bool includeAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (includeAuth) {
      final token = await StorageService.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  static Future<http.Response> get(String endpoint, {bool includeAuth = false}) async {
    try {
      final headers = await _getHeaders(includeAuth: includeAuth);
      return await http.get(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: headers,
      );
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<http.Response> post(
      String endpoint,
      Map<String, dynamic> body, {
        bool includeAuth = false,
      }) async {
    try {
      final headers = await _getHeaders(includeAuth: includeAuth);
      return await http.post(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: headers,
        body: jsonEncode(body),
      );
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<http.Response> put(
      String endpoint,
      Map<String, dynamic> body, {
        bool includeAuth = true,
      }) async {
    try {
      final headers = await _getHeaders(includeAuth: includeAuth);
      return await http.put(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: headers,
        body: jsonEncode(body),
      );
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<http.Response> delete(String endpoint, {bool includeAuth = true}) async {
    try {
      final headers = await _getHeaders(includeAuth: includeAuth);
      return await http.delete(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: headers,
      );
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // multipart upload
  static Future<http.Response> postMultipart(
      String endpoint,
      Map<String, String> fields,
      String fileField,
      List<int> fileBytes,
      String fileName, {
        bool includeAuth = true,
      }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
      );

      if (includeAuth) {
        final token = await StorageService.getToken();
        if (token != null) {
          request.headers['Authorization'] = 'Bearer $token';
        }
      }

      request.fields.addAll(fields);
      request.files.add(
        http.MultipartFile.fromBytes(fileField, fileBytes, filename: fileName),
      );

      final streamedResponse = await request.send();
      return await http.Response.fromStream(streamedResponse);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // multipart upload update
  static Future<http.Response> putMultipart(
      String endpoint,
      Map<String, String> fields,
      String? fileField,
      List<int>? fileBytes,
      String? fileName, {
        bool includeAuth = true,
      }) async {
    try {
      final request = http.MultipartRequest(
        'PUT',
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
      );

      if (includeAuth) {
        final token = await StorageService.getToken();
        if (token != null) {
          request.headers['Authorization'] = 'Bearer $token';
        }
      }

      request.fields.addAll(fields);

      if (fileBytes != null && fileName != null && fileField != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            fileField,
            fileBytes,
            filename: fileName,
          ),
        );
      }

      final streamedResponse = await request.send();
      return await http.Response.fromStream(streamedResponse);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}