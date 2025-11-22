import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_snackbar.dart';
import '../../services/payment_method_service.dart';
import '../../services/review_service.dart';
import '../../models/payment_method_model.dart';
import '../../utils/api_config.dart';
import 'payment_screen.dart';

class BookingScreen extends StatefulWidget {
  final Map<String, dynamic> destination;
  final Map<String, dynamic> transportation;
  final DateTime travelDate;
  final DateTime returnDate;
  final int guestCount;
  final bool isViewOnly;
  final String? selectedPaymentMethod;

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
  int _selectedPaymentMethod = -1;
  bool _isLoadingPaymentMethods = false;
  List<PaymentMethod> _paymentMethods = [];
  double _averageRating = 0.0;
  bool _isLoadingRating = false;
  final _formatter = NumberFormat('#,###', 'id_ID');

  @override
  void initState() {
    super.initState();
    _loadRating();
    if (!widget.isViewOnly) {
      _loadPaymentMethods();
    } else if (widget.selectedPaymentMethod != null) {
      _loadPaymentMethods().then((_) {
        final index = _paymentMethods.indexWhere(
          (method) => method.name == widget.selectedPaymentMethod,
        );
        if (mounted)
          setState(() => _selectedPaymentMethod = index >= 0 ? index : 0);
      });
    }
  }

  Future<void> _loadRating() async {
    setState(() => _isLoadingRating = true);
    try {
      final id = widget.destination['id'] as int?;
      if (id != null) {
        final reviews = await ReviewService.getDestinationReviews(id);
        if (reviews.isNotEmpty) {
          final total = reviews.fold<double>(0.0, (sum, r) => sum + r.rating);
          setState(() => _averageRating = total / reviews.length);
        }
      }
    } finally {
      if (mounted) setState(() => _isLoadingRating = false);
    }
  }

  Future<void> _loadPaymentMethods() async {
    setState(() => _isLoadingPaymentMethods = true);
    try {
      final methods = await PaymentMethodService.getPaymentMethods();
      if (mounted) {
        setState(() {
          _paymentMethods = methods;
          if (!widget.isViewOnly &&
              _selectedPaymentMethod == -1 &&
              methods.isNotEmpty) {
            _selectedPaymentMethod = 0;
          }
        });
      }
    } finally {
      if (mounted) setState(() => _isLoadingPaymentMethods = false);
    }
  }

  String _formatDate(DateTime d) {
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
    return "${weekdays[d.weekday - 1]}, ${d.day} ${months[d.month - 1]} ${d.year}, ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}";
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

  String _calculateTotalPrice() {
    final total = _getTransportPrice() + _getDestinationPrice();
    return "Rp ${_formatter.format(total)}";
  }

  String _formatPrice(int price) {
    return "Rp ${_formatter.format(price)}";
  }

  Icon _icon(String name, bool selected) {
    IconData i;
    switch (name.toLowerCase()) {
      case "credit card":
        i = Icons.credit_card;
        break;
      case "debit card":
        i = Icons.account_balance_wallet;
        break;
      case "bank transfer":
      case "transfer bank":
        i = Icons.account_balance;
        break;
      case "e-wallet":
        i = Icons.wallet;
        break;
      case "cash":
        i = Icons.money;
        break;
      default:
        i = Icons.payment;
    }
    return Icon(
      i,
      size: 24,
      color: selected ? AppColors.secondary : AppColors.textSecondary,
    );
  }

  void _openPaymentSelect() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey,
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
                      child: const Icon(Icons.close, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            if (_isLoadingPaymentMethods) const CircularProgressIndicator(),
            if (!_isLoadingPaymentMethods && _paymentMethods.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text("No payment methods available"),
              ),
            ..._paymentMethods.asMap().entries.map((e) {
              final selected = _selectedPaymentMethod == e.key;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedPaymentMethod = e.key);
                  Navigator.pop(context);
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 6,
                  ),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selected
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
                          color: selected
                              ? AppColors.secondary.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _icon(e.value.name, selected),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          e.value.name,
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (selected)
                        Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
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
                                widget.destination["location"],
                                style: valueStyle.copyWith(fontSize: 14),
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
                        if (_averageRating > 0 || widget.isViewOnly)
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
                          child: _box(
                            "Estimation",
                            Text(
                              widget.transportation["estimation"],
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

                    widget.isViewOnly
                        ? _cap(
                            Row(
                              children: [
                                SvgPicture.asset(
                                  "assets/icons/payment.svg",
                                  width: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  widget.selectedPaymentMethod ??
                                      "Not selected",
                                  style: valueStyle,
                                ),
                              ],
                            ),
                          )
                        : InkWell(
                            borderRadius: BorderRadius.circular(50),
                            onTap: _openPaymentSelect,
                            child: _cap(
                              Row(
                                children: [
                                  _selectedPaymentMethod != -1 &&
                                          _paymentMethods.isNotEmpty
                                      ? _icon(
                                          _paymentMethods[_selectedPaymentMethod]
                                              .name,
                                          true,
                                        )
                                      : const Icon(Icons.payment),
                                  const SizedBox(width: 12),
                                  Text(
                                    _selectedPaymentMethod == -1 ||
                                            _paymentMethods.isEmpty
                                        ? "Choose Payment Method"
                                        : _paymentMethods[_selectedPaymentMethod]
                                              .name,
                                    style: valueStyle,
                                  ),
                                ],
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
              decoration: const BoxDecoration(
                color: AppColors.background,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
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
                    InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () {
                        if (_selectedPaymentMethod == -1) {
                          showCustomSnackBar(
                            context,
                            "Please select a payment method",
                            isError: true,
                          );
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PaymentScreen(
                              paymentMethod:
                                  _paymentMethods[_selectedPaymentMethod].name,
                              totalPrice: _calculateTotalPrice(),
                              bookingDetails: {
                                "destination": widget.destination,
                                "transportation": widget.transportation,
                                "travelDate": widget.travelDate,
                                "returnDate": widget.returnDate,
                                "guestCount": widget.guestCount,
                                "paymentMethodId":
                                    _paymentMethods[_selectedPaymentMethod].id,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
}
