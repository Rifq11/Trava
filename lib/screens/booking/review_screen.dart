import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_snackbar.dart';

class ReviewScreen extends StatefulWidget {
  final Map<String, dynamic> destination;
  final Map<String, dynamic> transportation;
  final DateTime travelDate;
  final DateTime returnDate;
  final int guestCount;
  final String? selectedPaymentMethod;
  final String? userName;

  const ReviewScreen({
    super.key,
    required this.destination,
    required this.transportation,
    required this.travelDate,
    required this.returnDate,
    required this.guestCount,
    this.selectedPaymentMethod,
    this.userName,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int _rating = 0;
  final TextEditingController _reviewController = TextEditingController();

  String _formatDate(DateTime date) {
    final weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    final months = [
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
      'December'
    ];

    final weekday = weekdays[date.weekday - 1];
    final day = date.day;
    final month = months[date.month - 1];
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return "$weekday, $day $month $year, $hour:$minute";
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
                      child: SvgPicture.asset(
                        "assets/icons/arrow_next.svg",
                        width: 34,
                      ),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 60,
                            height: 3,
                            margin: const EdgeInsets.only(bottom: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Your ",
                                style: GoogleFonts.roboto(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                "Review",
                                style: GoogleFonts.roboto(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                              Text(
                                " Matters",
                                style: GoogleFonts.roboto(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (index) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _rating = index + 1;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Icon(
                                    index < _rating
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: index < _rating
                                        ? Colors.amber
                                        : Colors.grey,
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
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_rating == 0) {
                                  showCustomSnackBar(
                                    context,
                                    "Please select a rating",
                                    isError: true,
                                  );
                                  return;
                                }
                                // TODO: Save review to API
                                showCustomSnackBar(
                                  context,
                                  "Review saved successfully!",
                                  isSuccess: true,
                                );
                                Future.delayed(const Duration(milliseconds: 200), () {
                                  if (mounted) {
                                    Navigator.pop(context);
                                  }
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                "Save Review",
                                style: GoogleFonts.roboto(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Booking Info",
                            style: GoogleFonts.roboto(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  height: 280,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(32),
                                    image: DecorationImage(
                                      image: AssetImage(widget.destination["image"]),
                                      fit: BoxFit.cover,
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
                                              widget.destination["location"],
                                              style: valueStyle.copyWith(fontSize: 14),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    widget.destination["title"],
                                                    style: GoogleFonts.roboto(
                                                      fontSize: 22,
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  widget.destination["price"],
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
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                widget.destination["rating"] ?? "4.9",
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
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "General Info",
                            style: GoogleFonts.roboto(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),

                          _labelBox(
                            label: "Name",
                            child: Text(
                              widget.userName ?? "Salmah Nadya Safitri",
                              style: valueStyle,
                            ),
                          ),
                          const SizedBox(height: 16),

                          _labelBox(
                            label: "Travel Date",
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 18),
                                const SizedBox(width: 12),
                                Text(
                                  _formatDate(widget.travelDate),
                                  style: valueStyle,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          _labelBox(
                            label: "Return Date",
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 18),
                                const SizedBox(width: 12),
                                Text(
                                  _formatDate(widget.returnDate),
                                  style: valueStyle,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          _labelBox(
                            label: "Transportation",
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  widget.transportation["icon"],
                                  width: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  widget.transportation["name"],
                                  style: valueStyle,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: _labelBox(
                                  label: "Estimation",
                                  child: Text(
                                    widget.transportation["estimation"] ?? "4 Hari Perjalanan",
                                    style: valueStyle,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _labelBox(
                                  label: "Transportation Price",
                                  child: Text(
                                    widget.transportation["price"],
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
                                child: _labelBox(
                                  label: "Number of Guest",
                                  child: Text(
                                    "${widget.guestCount} Orang",
                                    style: valueStyle,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _labelBox(
                                  label: "Destination Price",
                                  child: Text(
                                    widget.destination["price"],
                                    style: valueStyle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          _labelBox(
                            label: "Payment Method",
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  "assets/icons/payment.svg",
                                  width: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  widget.selectedPaymentMethod ?? "Transfer Bank",
                                  style: valueStyle,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          Center(
                            child: SvgPicture.asset(
                              "assets/icons/trava_logo.svg",
                              width: 100,
                              height: 40,
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _labelBox({required String label, required Widget child}) {
    return Column(
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
        _capsule(child: child),
      ],
    );
  }

  Widget _capsule({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }

}

