class Booking {
  final int id;
  final int userId;
  final int destinationId;
  final int transportationId;
  final int paymentMethodId;
  final int statusId;
  final int peopleCount;
  final String startDate;
  final String endDate;
  final int transportPrice;
  final int destinationPrice;
  final int totalPrice;

  Booking({
    required this.id,
    required this.userId,
    required this.destinationId,
    required this.transportationId,
    required this.paymentMethodId,
    required this.statusId,
    required this.peopleCount,
    required this.startDate,
    required this.endDate,
    required this.transportPrice,
    required this.destinationPrice,
    required this.totalPrice,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      destinationId: json['destination_id'] ?? 0,
      transportationId: json['transportation_id'] ?? 0,
      paymentMethodId: json['payment_method_id'] ?? 0,
      statusId: json['status_id'] ?? 0,
      peopleCount: json['people_count'] ?? 0,
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      transportPrice: json['transport_price'] ?? 0,
      destinationPrice: json['destination_price'] ?? 0,
      totalPrice: json['total_price'] ?? 0,
    );
  }
}

class BookingResponse {
  final int bookingId;
  final int destinationId;
  final String destinationName;
  final String location;
  final int peopleCount;
  final String startDate;
  final String endDate;
  final int totalPrice;
  final int transportPrice;
  final int destinationPrice;
  final String statusName;
  final String paymentMethodName;
  final String? destinationImage;

  BookingResponse({
    required this.bookingId,
    required this.destinationId,
    required this.destinationName,
    required this.location,
    required this.peopleCount,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.transportPrice,
    required this.destinationPrice,
    required this.statusName,
    required this.paymentMethodName,
    this.destinationImage,
  });

  factory BookingResponse.fromJson(Map<String, dynamic> json) {
    return BookingResponse(
      bookingId: json['booking_id'] ?? json['id'] ?? 0,
      destinationId: json['destination_id'] ?? 0,
      destinationName: json['destination_name'] ?? '',
      location: json['location'] ?? '',
      peopleCount: json['people_count'] ?? 0,
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      totalPrice: json['total_price'] ?? 0,
      transportPrice: json['transport_price'] ?? 0,
      destinationPrice: json['destination_price'] ?? 0,
      statusName: json['status_name'] ?? '',
      paymentMethodName: json['payment_method_name'] ?? '',
      destinationImage: json['destination_image'],
    );
  }
}

class CreateBookingRequest {
  final int destinationId;
  final int transportationId;
  final int paymentMethodId;
  final int peopleCount;
  final String startDate;
  final String endDate;

  CreateBookingRequest({
    required this.destinationId,
    required this.transportationId,
    required this.paymentMethodId,
    required this.peopleCount,
    required this.startDate,
    required this.endDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'destination_id': destinationId,
      'transportation_id': transportationId,
      'payment_method_id': paymentMethodId,
      'people_count': peopleCount,
      'start_date': startDate,
      'end_date': endDate,
    };
  }
}

