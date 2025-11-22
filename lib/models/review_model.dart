class Review {
  final int id;
  final int bookingId;
  final int userId;
  final int rating;
  final String reviewText;

  Review({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.rating,
    required this.reviewText,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? 0,
      bookingId: json['booking_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      rating: json['rating'] ?? 0,
      reviewText: json['review_text'] ?? '',
    );
  }
}

class ReviewResponse {
  final int id;
  final int bookingId;
  final int userId;
  final String userName;
  final int rating;
  final String reviewText;

  ReviewResponse({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.reviewText,
  });

  factory ReviewResponse.fromJson(Map<String, dynamic> json) {
    return ReviewResponse(
      id: json['id'] ?? 0,
      bookingId: json['booking_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      userName: json['user_name'] ?? '',
      rating: json['rating'] ?? 0,
      reviewText: json['review_text'] ?? '',
    );
  }
}

class CreateReviewRequest {
  final int bookingId;
  final int rating;
  final String reviewText;

  CreateReviewRequest({
    required this.bookingId,
    required this.rating,
    required this.reviewText,
  });

  Map<String, dynamic> toJson() {
    return {
      'booking_id': bookingId,
      'rating': rating,
      'review_text': reviewText,
    };
  }
}

