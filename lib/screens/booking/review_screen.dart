import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_snackbar.dart';
import '../../services/review_service.dart';
import '../../services/profile_service.dart';
import '../../models/review_model.dart';
import '../../utils/api_config.dart';
import '../../utils/error_formatter.dart';

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
    const months = [
      'January','February','March','April','May','June',
      'July','August','September','October','November','December'
    ];

    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final valueStyle = GoogleFonts.roboto(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
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