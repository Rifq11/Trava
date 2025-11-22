import 'dart:convert';
import '../models/auth_model.dart';
import '../services/api_service.dart';
import '../utils/api_config.dart';
import '../utils/storage_service.dart';

class AuthService {
  static Future<AuthResponse> register(RegisterRequest request) async {
    final response = await ApiService.post(
      ApiConfig.register,
      request.toJson(),
      includeAuth: false,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final authResponse = AuthResponse.fromJson(data['data']);
      
      return authResponse;
    } else {
      final errorData = jsonDecode(response.body);
      final errorMessage = errorData['error'] ?? errorData['message'] ?? 'Registration failed';
      throw Exception(errorMessage);
    }
  }

  static Future<AuthResponse> login(LoginRequest request) async {
    final response = await ApiService.post(
      ApiConfig.login,
      request.toJson(),
      includeAuth: false,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final authResponse = AuthResponse.fromJson(data['data']);
      
      await StorageService.saveToken(authResponse.token);
      await StorageService.saveUserData(
        userId: authResponse.userId,
        email: authResponse.email,
        name: authResponse.fullName,
      );
      
      return authResponse;
    } else {
      final errorData = jsonDecode(response.body);
      final errorMessage = errorData['error'] ?? errorData['message'] ?? 'Login failed';
      throw Exception(errorMessage);
    }
  }

  static Future<void> logout() async {
    await StorageService.removeToken();
    await StorageService.clearUserData();
  }

  static Future<bool> isLoggedIn() async {
    return await StorageService.isLoggedIn();
  }
}

