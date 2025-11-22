class Payment {
  final int id;
  final int bookingId;
  final int amount;
  final String paymentStatus;

  Payment({
    required this.id,
    required this.bookingId,
    required this.amount,
    required this.paymentStatus,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] ?? 0,
      bookingId: json['booking_id'] ?? 0,
      amount: json['amount'] ?? 0,
      paymentStatus: json['payment_status'] ?? '',
    );
  }
}

class CreatePaymentRequest {
  final int bookingId;
  final int amount;

  CreatePaymentRequest({
    required this.bookingId,
    required this.amount,
  });

  Map<String, dynamic> toJson() {
    return {
      'booking_id': bookingId,
      'amount': amount,
    };
  }
}

class UpdatePaymentRequest {
  final String paymentStatus;

  UpdatePaymentRequest({
    required this.paymentStatus,
  });

  Map<String, dynamic> toJson() {
    return {
      'payment_status': paymentStatus,
    };
  }
}

