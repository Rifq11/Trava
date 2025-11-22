import 'dart:convert';
import '../models/payment_method_model.dart';
import '../services/api_service.dart';
import '../utils/api_config.dart';

class PaymentMethodService {
  static Future<List<PaymentMethod>> getPaymentMethods() async {
    final response = await ApiService.get(
      ApiConfig.paymentMethods,
      includeAuth: false,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> paymentMethodsJson = data['data'] ?? [];
      return paymentMethodsJson
          .map((json) => PaymentMethod.fromJson(json))
          .toList();
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to get payment methods');
    }
  }
}

