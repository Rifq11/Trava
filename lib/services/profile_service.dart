import 'dart:convert';
import 'dart:io';
import '../models/profile_model.dart';
import '../services/api_service.dart';
import '../utils/api_config.dart';

class ProfileService {
  static Future<ProfileResponse> getProfile() async {
    final response = await ApiService.get(
      ApiConfig.getProfile,
      includeAuth: true,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ProfileResponse.fromJson(data['data']);
    } else {
      final errorData = jsonDecode(response.body);
      final errorMessage =
          errorData['error'] ?? errorData['message'] ?? 'Failed to get profile';
      throw Exception(errorMessage);
    }
  }

  static Future<void> completeProfile(
    CompleteProfileRequest request, {
    File? photoFile,
  }) async {
    final fields = <String, String>{};

    if (request.phone != null) fields['phone'] = request.phone!;
    if (request.address != null) fields['address'] = request.address!;
    if (request.birthDate != null) {
      String birthDate = request.birthDate!;
      if (birthDate.contains('T')) birthDate = birthDate.split('T')[0];
      birthDate = birthDate.replaceAll('Z', '');
      if (birthDate.length > 10) birthDate = birthDate.substring(0, 10);
      fields['birth_date'] = birthDate;
    }

    var response;

    if (photoFile != null && await photoFile.exists()) {
      final fileBytes = await photoFile.readAsBytes();
      response = await ApiService.putMultipart(
        ApiConfig.completeProfile,
        fields,
        'user_photo',
        fileBytes,
        photoFile.path.split('/').last,
        includeAuth: true,
      );
    } else {
      response = await ApiService.putMultipart(
        ApiConfig.completeProfile,
        fields,
        null,
        null,
        null,
        includeAuth: true,
      );
    }

    if (response.statusCode != 200) {
      final errorData = jsonDecode(response.body);
      final errorMessage =
          errorData['error'] ?? errorData['message'] ?? 'Failed to complete profile';
      throw Exception(errorMessage);
    }
  }

  static Future<void> updateProfile(
    UpdateProfileRequest request, {
    File? photoFile,
  }) async {
    final fields = <String, String>{};

    if (request.fullName != null) fields['full_name'] = request.fullName!;
    if (request.email != null) fields['email'] = request.email!;
    if (request.phone != null) fields['phone'] = request.phone!;
    if (request.address != null) fields['address'] = request.address!;
    if (request.birthDate != null) {
      String birthDate = request.birthDate!;
      if (birthDate.contains('T')) birthDate = birthDate.split('T')[0];
      birthDate = birthDate.replaceAll('Z', '');
      if (birthDate.length > 10) birthDate = birthDate.substring(0, 10);
      fields['birth_date'] = birthDate;
    }
    if (request.password != null) fields['password'] = request.password!;

    var response;

    if (photoFile != null && await photoFile.exists()) {
      final fileBytes = await photoFile.readAsBytes();
      response = await ApiService.putMultipart(
        ApiConfig.updateProfile,
        fields,
        'user_photo',
        fileBytes,
        photoFile.path.split('/').last,
        includeAuth: true,
      );
    } else {
      response = await ApiService.putMultipart(
        ApiConfig.updateProfile,
        fields,
        null,
        null,
        null,
        includeAuth: true,
      );
    }

    if (response.statusCode != 200) {
      final errorData = jsonDecode(response.body);
      final errorMessage =
          errorData['error'] ?? errorData['message'] ?? 'Failed to update profile';
      throw Exception(errorMessage);
    }
  }
}