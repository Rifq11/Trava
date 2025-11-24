class ApiConfig {
  static const String baseUrl = 'http://10.67.72.13:8080/api'; // use ip to connect as local

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String updateProfile = '/auth/profile';

  // Profile
  static const String getProfile = '/profile';
  static const String completeProfile = '/profile/complete';

  // Destination
  static const String destinations = '/destinations';
  static const String destinationCategories = '/destinations/categories';
  static String destinationById(int id) => '/destinations/$id';

  // Transportation
  static String transportationsByDestination(int id) =>
      '/transportations/destination/$id';

  // Booking
  static const String bookings = '/bookings';
  static const String myBookings = '/bookings/my';
  static String bookingById(int id) => '/bookings/$id';
  static String cancelBooking(int id) => '/bookings/$id/cancel';

  // Payment
  static const String payments = '/payments';
  static String paymentById(int id) => '/payments/$id';

  // Payment Method
  static const String paymentMethods = '/payment-methods';

  // Review
  static const String reviews = '/reviews';
  static String destinationReviews(int id) => '/reviews/destination/$id';
  static String bookingReview(int id) => '/reviews/booking/$id';
}
