import 'dart:convert';
import '../models/booking_model.dart';
import '../services/api_service.dart';
import '../utils/api_config.dart';

class BookingService {
  static Future<Booking> createBooking(CreateBookingRequest request) async {
    final response = await ApiService.post(
      ApiConfig.bookings,
      request.toJson(),
      includeAuth: true,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Booking.fromJson(data['data']);
    } else {
      final errorData = jsonDecode(response.body);
      final errorMessage = errorData['error'] ?? errorData['message'] ?? 'Failed to create booking';
      throw Exception(errorMessage);
    }
  }

  static Future<List<BookingResponse>> getMyBookings() async {
    final response = await ApiService.get(
      ApiConfig.myBookings,
      includeAuth: true,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> bookingsJson = data['data'] ?? [];
      return bookingsJson
          .map((json) => BookingResponse.fromJson(json))
          .toList();
    } else {
      final errorData = jsonDecode(response.body);
      final errorMessage = errorData['error'] ?? errorData['message'] ?? 'Failed to get bookings';
      throw Exception(errorMessage);
    }
  }

  static Future<Booking> getBookingById(int id) async {
    final response = await ApiService.get(
      ApiConfig.bookingById(id),
      includeAuth: true,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Booking.fromJson(data['data']);
    } else {
      final errorData = jsonDecode(response.body);
      final errorMessage = errorData['error'] ?? errorData['message'] ?? 'Failed to get booking';
      throw Exception(errorMessage);
    }
  }

  static Future<void> cancelBooking(int bookingId) async {
    final response = await ApiService.put(
      ApiConfig.cancelBooking(bookingId),
      {},
      includeAuth: true,
    );

    if (response.statusCode != 200) {
      final errorData = jsonDecode(response.body);
      final errorMessage = errorData['error'] ?? errorData['message'] ?? 'Failed to cancel booking';
      throw Exception(errorMessage);
    }
  }
}

