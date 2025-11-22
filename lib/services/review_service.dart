import 'dart:convert';
import '../models/review_model.dart';
import '../services/api_service.dart';
import '../utils/api_config.dart';

class ReviewService {
  static Future<Review> createReview(CreateReviewRequest request) async {
    final response = await ApiService.post(
      ApiConfig.reviews,
      request.toJson(),
      includeAuth: true,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Review.fromJson(data['data']);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to create review');
    }
  }

  static Future<List<ReviewResponse>> getDestinationReviews(int destinationId) async {
    final response = await ApiService.get(
      ApiConfig.destinationReviews(destinationId),
      includeAuth: false,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> reviewsJson = data['data'] ?? [];
      return reviewsJson
          .map((json) => ReviewResponse.fromJson(json))
          .toList();
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to get reviews');
    }
  }

  static Future<Review?> getReviewByBookingId(int bookingId) async {
    final response = await ApiService.get(
      ApiConfig.bookingReview(bookingId),
      includeAuth: true,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['data'] == null) {
        return null;
      }
      return Review.fromJson(data['data']);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to get review');
    }
  }
}

