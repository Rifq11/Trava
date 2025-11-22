import 'dart:convert';
import '../models/transportation_model.dart';
import '../services/api_service.dart';
import '../utils/api_config.dart';

class TransportationService {
  static Future<List<Transportation>> getTransportationsByDestination(int destinationId) async {
    final response = await ApiService.get(
      ApiConfig.transportationsByDestination(destinationId),
      includeAuth: false,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> transportationsJson = data['data'] ?? [];
      return transportationsJson
          .map((json) => Transportation.fromJson(json))
          .toList();
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to get transportations');
    }
  }
}

