import 'dart:convert';
import '../models/destination_model.dart';
import '../services/api_service.dart';
import '../utils/api_config.dart';

class DestinationService {
  static Future<List<Destination>> getDestinations() async {
    final response = await ApiService.get(
      ApiConfig.destinations,
      includeAuth: false,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> destinationsJson = data['data'] ?? [];
      return destinationsJson
          .map((json) => Destination.fromJson(json))
          .toList();
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to get destinations');
    }
  }

  static Future<Destination> getDestinationById(int id) async {
    final response = await ApiService.get(
      ApiConfig.destinationById(id),
      includeAuth: false,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Destination.fromJson(data['data']);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to get destination');
    }
  }

  static Future<List<Destination>> getDestinationsByCategory(int? categoryId) async {
    String endpoint = ApiConfig.destinations;
    if (categoryId != null && categoryId > 0) {
      endpoint = '${ApiConfig.destinations}?category_id=$categoryId';
    }
    
    final response = await ApiService.get(
      endpoint,
      includeAuth: false,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> destinationsJson = data['data'] ?? [];
      return destinationsJson
          .map((json) => Destination.fromJson(json))
          .toList();
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to get destinations');
    }
  }

  static Future<List<DestinationCategory>> getCategories() async {
    final response = await ApiService.get(
      ApiConfig.destinationCategories,
      includeAuth: false,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> categoriesJson = data['data'] ?? [];
      return categoriesJson
          .map((json) => DestinationCategory.fromJson(json))
          .toList();
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to get categories');
    }
  }

  static Future<List<Destination>> searchDestinations(String query) async {
    final encodedQuery = Uri.encodeComponent(query);
    final response = await ApiService.get(
      '${ApiConfig.destinations}?search=$encodedQuery',
      includeAuth: false,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> destinationsJson = data['data'] ?? [];
      return destinationsJson
          .map((json) => Destination.fromJson(json))
          .toList();
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to search destinations');
    }
  }
}

