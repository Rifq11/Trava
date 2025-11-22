import 'dart:convert';
import '../models/payment_model.dart';
import '../services/api_service.dart';
import '../utils/api_config.dart';

class PaymentService {
  static Future<Payment> initiatePayment(CreatePaymentRequest request) async {
    final response = await ApiService.post(
      ApiConfig.payments,
      request.toJson(),
      includeAuth: false,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Payment.fromJson(data['data']);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to initiate payment');
    }
  }

  static Future<Payment> updatePayment(int id, UpdatePaymentRequest request) async {
    final response = await ApiService.put(
      ApiConfig.paymentById(id),
      request.toJson(),
      includeAuth: false,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Payment.fromJson(data['data']);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to update payment');
    }
  }
}

