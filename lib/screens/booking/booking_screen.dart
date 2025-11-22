import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_snackbar.dart';
import 'payment_screen.dart';

class BookingScreen extends StatefulWidget {
  final Map<String, dynamic> destination;
  final Map<String, dynamic> transportation;
  final DateTime travelDate;
  final DateTime returnDate;
  final int guestCount;
  final bool isViewOnly;
  final String? selectedPaymentMethod; // For view-only mode

  const BookingScreen({
    super.key,
    required this.destination,
    required this.transportation,
    required this.travelDate,
    required this.returnDate,
    required this.guestCount,
    this.isViewOnly = false,
    this.selectedPaymentMethod,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late int _selectedPaymentMethod;

  final List<Map<String, dynamic>> paymentMethods = [
    {"name": "Credit Card"},
    {"name": "Transfer Bank"},
    {"name": "E-Wallet"},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isViewOnly && widget.selectedPaymentMethod != null) {
      _selectedPaymentMethod = paymentMethods.indexWhere(
        (method) => method["name"] == widget.selectedPaymentMethod,
      );
      if (_selectedPaymentMethod == -1) {
        _selectedPaymentMethod = 0;
      }
    } else {
      _selectedPaymentMethod = -1;
    }
  }

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

  String _calculateTotalPrice() {
    final destinationPriceStr =
        (widget.destination["price"] ?? "Rp. 100.000 /person")
            .replaceAll("Rp. ", "")
            .replaceAll(" /person", "")
            .replaceAll(".", "");
    final destinationPrice = int.tryParse(destinationPriceStr) ?? 100000;

    final transportPriceStr =
        (widget.transportation["price"] ?? "Rp. 1.000.000")
            .replaceAll("Rp. ", "")
            .replaceAll(".", "");
    final transportPrice = int.tryParse(transportPriceStr) ?? 1000000;

    final total = (destinationPrice * widget.guestCount) + transportPrice;

    return "Rp. ${total.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
  }

  void _openPaymentMethodSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Select Payment Method",
                    style: GoogleFonts.roboto(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ...paymentMethods.asMap().entries.map((entry) {
              final index = entry.key;
              final method = entry.value;
              final isSelected = _selectedPaymentMethod == index;

              return GestureDetector(
                onTap: () {
                  setState(() => _selectedPaymentMethod = index);
                  Navigator.pop(context);
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.secondary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.secondary.withOpacity(0.1)
                              : AppColors.textSecondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: SvgPicture.asset(
                          "assets/icons/payment.svg",
                          width: 24,
                          height: 24,
                          colorFilter: ColorFilter.mode(
                            isSelected
                                ? AppColors.secondary
                                : AppColors.textSecondary,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          method["name"],
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final labelStyle = GoogleFonts.roboto(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.textSecondary,
    );

    final valueStyle = GoogleFonts.roboto(
      fontSize: 16,
      fontWeight: FontWeight.w600,
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
                        widget.isViewOnly ? "Booking Info" : "Booking Form",
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

            const SizedBox(height: 24),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "General Info",
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _labelBox(
                      label: "Name",
                      child: Text("Salmah Nadya Safitri", style: valueStyle),
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
                              widget.transportation["estimation"],
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

                    Text("Payment Method", style: labelStyle),
                    const SizedBox(height: 8),

                    widget.isViewOnly
                        ? _capsule(
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  "assets/icons/payment.svg",
                                  width: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  widget.selectedPaymentMethod ??
                                      (_selectedPaymentMethod != -1
                                          ? paymentMethods[_selectedPaymentMethod]["name"]
                                          : "Not selected"),
                                  style: valueStyle,
                                ),
                              ],
                            ),
                          )
                        : Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(50),
                              onTap: _openPaymentMethodSelector,
                              child: _capsule(
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      "assets/icons/payment.svg",
                                      width: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      _selectedPaymentMethod == -1
                                          ? "Choose Payment Method"
                                          : paymentMethods[_selectedPaymentMethod]["name"],
                                      style: valueStyle,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.background,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Total Harga", style: labelStyle),
                      Text(
                        _calculateTotalPrice(),
                        style: GoogleFonts.roboto(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (!widget.isViewOnly)
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(50),
                        onTap: () {
                          if (_selectedPaymentMethod == -1) {
                            showCustomSnackBar(context, "Please select a payment method", isError: true);
                            return;
                          }
                          
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentScreen(
                                paymentMethod: paymentMethods[_selectedPaymentMethod]["name"],
                                totalPrice: _calculateTotalPrice(),
                                bookingDetails: {
                                  "destination": widget.destination,
                                  "transportation": widget.transportation,
                                  "travelDate": widget.travelDate,
                                  "returnDate": widget.returnDate,
                                  "guestCount": widget.guestCount,
                                },
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 100,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            "Pay Now",
                            style: GoogleFonts.roboto(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
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
