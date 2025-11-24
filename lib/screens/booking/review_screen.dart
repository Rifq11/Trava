import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_snackbar.dart';
import '../../services/review_service.dart';
import '../../services/profile_service.dart';
import '../../models/review_model.dart';
import '../../utils/error_formatter.dart';
import '../../utils/api_config.dart';

class ReviewScreen extends StatefulWidget {
  final Map<String, dynamic> destination;
  final Map<String, dynamic> transportation;
  final DateTime travelDate;
  final DateTime returnDate;
  final int guestCount;
  final String? selectedPaymentMethod;
  final String? userName;
  final int? destinationPrice;
  final int? transportPrice;

  const ReviewScreen({
    super.key,
    required this.destination,
    required this.transportation,
    required this.travelDate,
    required this.returnDate,
    required this.guestCount,
    this.selectedPaymentMethod,
    this.userName,
    this.destinationPrice,
    this.transportPrice,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int _rating = 0;
  final TextEditingController _reviewController = TextEditingController();
  bool _isLoading = false;
  String _userName = "";
  int? _bookingId;
  double _averageRating = 0.0;
  bool _isLoadingRating = false;
  final _formatter = NumberFormat('#,###', 'id_ID');

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadRating();
    if (widget.destination.containsKey('id')) {
      _bookingId = widget.destination['id'] as int?;
      _loadExistingReview();
    }
  }

  Future<void> _loadExistingReview() async {
    if (_bookingId == null) return;
    try {
      final review = await ReviewService.getReviewByBookingId(_bookingId!);
      if (review != null && mounted) {
        setState(() {
          _rating = review.rating;
          _reviewController.text = review.reviewText;
        });
      }
    } catch (e) {}
  }

  Future<void> _loadRating() async {
    setState(() => _isLoadingRating = true);
    try {
      final destinationId = widget.destination['destination_id'] as int?;
      if (destinationId != null) {
        final reviews = await ReviewService.getDestinationReviews(destinationId);
        if (reviews.isNotEmpty) {
          final totalRating =
              reviews.fold<double>(0.0, (sum, review) => sum + review.rating);
          setState(() => _averageRating = totalRating / reviews.length);
        } else {
          setState(() => _averageRating = 0.0);
        }
      } else {
        setState(() => _averageRating = 0.0);
      }
    } catch (e) {
      setState(() => _averageRating = 0.0);
    } finally {
      if (mounted) setState(() => _isLoadingRating = false);
    }
  }

  Future<void> _loadUserName() async {
    try {
      final profile = await ProfileService.getProfile();
      if (mounted) setState(() => _userName = profile.user.fullName);
    } catch (e) {
      if (mounted) setState(() => _userName = widget.userName ?? '');
    }
  }

  String _formatDate(DateTime date) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return "${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  int _getTransportPrice() {
    if (widget.transportation["price"] is int)
      return widget.transportation["price"];
    if (widget.transportation["price"] is String) {
      return int.tryParse(
            widget.transportation["price"]
                .replaceAll("Rp. ", "")
                .replaceAll(".", "")
                .trim(),
          ) ??
          0;
    }
    return 0;
  }

  int _getDestinationPricePerPerson() {
    if (widget.destinationPrice != null) return widget.destinationPrice!;
    if (widget.destination["price_per_person"] is int)
      return widget.destination["price_per_person"];
    if (widget.destination["price_per_person"] is String) {
      return int.tryParse(widget.destination["price_per_person"]) ?? 0;
    }
    if (widget.destination["price"] != null) {
      return int.tryParse(
            widget.destination["price"]
                .replaceAll("Rp. ", "")
                .replaceAll(" /person", "")
                .replaceAll(".", ""),
          ) ??
          0;
    }
    return 0;
  }

  int _getDestinationPrice() =>
      _getDestinationPricePerPerson() * widget.guestCount;

  String _formatPrice(int price) {
    return "Rp ${_formatter.format(price)}";
  }

  Widget _box(String label, Widget child) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          _cap(child),
        ],
      );

  Widget _cap(Widget child) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: child,
      );

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final valueStyle = GoogleFonts.roboto(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    );
    final labelStyle = GoogleFonts.roboto(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.textSecondary,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(3.14159),
                      child: SvgPicture.asset("assets/icons/arrow_next.svg", width: 34),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        "Review",
                        style: GoogleFonts.roboto(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 34),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 56,
                            height: 3,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 8),
                          RichText(
                            text: TextSpan(
                              style: GoogleFonts.roboto(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              children: [
                                const TextSpan(text: "Your "),
                                TextSpan(
                                  text: "Review",
                                  style: GoogleFonts.roboto(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const TextSpan(text: " Matter"),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: () => setState(() => _rating = index + 1),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Icon(
                              index < _rating ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 40,
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),

                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        controller: _reviewController,
                        maxLines: 6,
                        decoration: InputDecoration(
                          hintText: "Tell us about your journey",
                          hintStyle: GoogleFonts.roboto(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () async {
                                FocusScope.of(context).unfocus();

                                if (_rating == 0) {
                                  showCustomSnackBar(context, "Please select a rating",
                                      isError: true);
                                  return;
                                }

                                if (_bookingId == null) {
                                  showCustomSnackBar(context, "Booking ID not found",
                                      isError: true);
                                  return;
                                }

                                setState(() => _isLoading = true);

                                try {
                                  final request = CreateReviewRequest(
                                    bookingId: _bookingId!,
                                    rating: _rating,
                                    reviewText: _reviewController.text.trim(),
                                  );

                                  await ReviewService.createReview(request);

                                  if (mounted) {
                                    showCustomSnackBar(
                                      context,
                                      "Review saved successfully!",
                                      isSuccess: true,
                                    );
                                    Future.delayed(const Duration(milliseconds: 500), () {
                                      if (mounted) Navigator.pop(context);
                                    });
                                  }

                                } catch (e, stackTrace) {
                                  debugPrint("Error saving review: $e");
                                  debugPrint("Stacktrace: $stackTrace");

                                  if (mounted) {
                                    final msg = ErrorFormatter.format(e.toString());
                                    showCustomSnackBar(
                                      context,
                                      msg,
                                      isError: true,
                                    );
                                  }

                                } finally {
                                  if (mounted) setState(() => _isLoading = false);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                "Save Review",
                                style: GoogleFonts.roboto(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            height: 280,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(32),
                              color: Colors.grey[300],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(32),
                              child: SizedBox.expand(
                                child:
                                    widget.destination["image"] != null &&
                                        widget.destination["image"]
                                            .toString()
                                            .isNotEmpty
                                    ? Image.network(
                                        "${ApiConfig.baseUrl.replaceAll('/api', '')}${widget.destination["image"]}",
                                        fit: BoxFit.cover,
                                        errorBuilder: (c, e, s) => Container(
                                          color: Colors.grey[300],
                                          child: const Center(
                                            child: Icon(
                                              Icons.image_not_supported,
                                              size: 50,
                                            ),
                                          ),
                                        ),
                                        loadingBuilder: (c, child, progress) =>
                                            progress == null
                                            ? child
                                            : Container(
                                                color: Colors.grey[300],
                                                child: const Center(
                                                  child: CircularProgressIndicator(),
                                                ),
                                              ),
                                      )
                                    : Container(
                                        color: Colors.grey[300],
                                        child: const Center(
                                          child: Icon(
                                            Icons.image_not_supported,
                                            size: 50,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          ),

                          Positioned(
                            bottom: 28,
                            left: 16,
                            right: 16,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(32),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.destination["location"] ?? "",
                                        style: GoogleFonts.roboto(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              widget.destination["name"] ??
                                                  widget.destination["title"] ??
                                                  "",
                                              style: GoogleFonts.roboto(
                                                fontSize: 22,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            widget.destination["price_per_person"] !=
                                                        null &&
                                                    widget.destination["price_per_person"] !=
                                                        0
                                                ? _formatPrice(
                                                    widget.destination["price_per_person"]
                                                        as int,
                                                  )
                                                : (widget.destination["price"] !=
                                                              null &&
                                                          widget.destination["price"]
                                                              .toString()
                                                              .isNotEmpty
                                                      ? widget.destination["price"]
                                                            .toString()
                                                      : ""),
                                            style: GoogleFonts.roboto(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  top: -14,
                                  right: 20,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.85),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _isLoadingRating
                                              ? "..."
                                              : (_averageRating > 0
                                                    ? _averageRating.toStringAsFixed(
                                                        1,
                                                      )
                                                    : "0.0"),
                                          style: GoogleFonts.roboto(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    Text(
                      "General Info",
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _box(
                      "Destination",
                      Text(
                        widget.destination["name"] ??
                            widget.destination["title"] ??
                            "",
                        style: valueStyle,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _box(
                      "Travel Date",
                      Row(
                        children: [
                          const Icon(Icons.calendar_today),
                          const SizedBox(width: 12),
                          Text(
                            _formatDate(widget.travelDate),
                            style: valueStyle,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    _box(
                      "Return Date",
                      Row(
                        children: [
                          const Icon(Icons.calendar_today),
                          const SizedBox(width: 12),
                          Text(
                            _formatDate(widget.returnDate),
                            style: valueStyle,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    _box(
                      "Transportation",
                      Row(
                        children: [
                          widget.transportation["icon"] != null
                              ? SvgPicture.asset(
                                  widget.transportation["icon"],
                                  width: 24,
                                )
                              : const Icon(Icons.directions_car),
                          const SizedBox(width: 12),
                          Text(
                            widget.transportation["name"] ?? "",
                            style: valueStyle,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _box(
                            "Estimation",
                            Text(
                              widget.transportation["estimation"] ?? "",
                              style: valueStyle,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _box(
                            "Transportation Price",
                            Text(
                              _formatPrice(_getTransportPrice()),
                              style: valueStyle,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _box(
                            "Number of Guest",
                            Text(
                              "${widget.guestCount} Orang",
                              style: valueStyle,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _box(
                            "Destination Price",
                            Text(
                              _formatPrice(_getDestinationPrice()),
                              style: valueStyle,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Text("Payment Method", style: labelStyle),
                    const SizedBox(height: 8),
                    _cap(
                      Row(
                        children: [
                          SvgPicture.asset(
                            "assets/icons/payment.svg",
                            width: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            widget.selectedPaymentMethod ?? "Not selected",
                            style: valueStyle,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    Center(
                      child: SvgPicture.asset(
                        "assets/icons/trava_logo.svg",
                        width: 120,
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}