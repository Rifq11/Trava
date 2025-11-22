import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../widgets/bottom_bar/custom_bottom_bar.dart';
import '../../services/booking_service.dart';
import '../../models/booking_model.dart';
import '../../utils/api_config.dart';
import '../../widgets/custom_snackbar.dart';
import '../../utils/error_formatter.dart';
import '../home/home_screen.dart';
import '../destination/destination_screen.dart';
import '../booking/booking_screen.dart';
import '../destination/detail_destination_screen.dart';
import '../booking/review_screen.dart';
import '../profile/profile_screen.dart';
import '../../services/destination_service.dart';

class MyTripScreen extends StatefulWidget {
  const MyTripScreen({super.key});

  @override
  State<MyTripScreen> createState() => _MyTripScreenState();
}

class _MyTripScreenState extends State<MyTripScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentBottomNavIndex = 2; // 2 = My Trip
  bool _isLoading = false;

  List<BookingResponse> _ongoingOrders = [];
  List<BookingResponse> _historyOrders = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadBookings();
  }

  Future<void> _handleCancelBooking(int bookingId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Cancel Booking",
          style: GoogleFonts.roboto(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          "Are you sure you want to cancel this booking?",
          style: GoogleFonts.roboto(
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              "No",
              style: GoogleFonts.roboto(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              "Yes",
              style: GoogleFonts.roboto(
                color: AppColors.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await BookingService.cancelBooking(bookingId);
      if (mounted) {
        showCustomSnackBar(
          context,
          "Booking canceled successfully",
          isSuccess: true,
        );
        _loadBookings();
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = ErrorFormatter.format(e.toString());
        showCustomSnackBar(
          context,
          errorMessage,
          isSuccess: false,
        );
      }
    }
  }

  Future<void> _navigateToDetailDestination(BookingResponse order) async {
    try {
      final destination = await DestinationService.getDestinationById(order.destinationId);
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailDestinationScreen(
              destination: {
                "id": destination.id,
                "image": destination.image,
                "location": destination.location,
                "name": destination.name,
                "title": destination.name,
                "price_per_person": destination.pricePerPerson,
                "description": destination.description,
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = ErrorFormatter.format(e.toString());
        showCustomSnackBar(
          context,
          errorMessage,
          isSuccess: false,
        );
      }
    }
  }


  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final bookings = await BookingService.getMyBookings();
      setState(() {
        _ongoingOrders = bookings.where((b) {
          final status = b.statusName.toLowerCase();
          return status == 'pending' || 
                 status == 'approved';
        }).toList();
        _historyOrders = bookings.where((b) {
          final status = b.statusName.toLowerCase();
          return status == 'completed' || 
                 status == 'canceled' || 
                 status == 'rejected';
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        final errorMessage = ErrorFormatter.format(e.toString());
        showCustomSnackBar(
          context,
          errorMessage,
          isSuccess: false,
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildOrderCard(BookingResponse order, {bool isOngoing = false}) {
    Color statusColor;
    switch (order.statusName.toLowerCase()) {
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'completed':
        statusColor = Colors.blue;
        break;
      case 'canceled':
        statusColor = Colors.black;
        break;
      default:
        statusColor = Colors.grey;
    }

    final priceFormatted = "Rp. ${order.totalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";

    final imageUrl = order.destinationImage != null && order.destinationImage!.isNotEmpty
        ? '${ApiConfig.baseUrl.replaceAll('/api', '')}${order.destinationImage}'
        : null;
    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        height: 280,
        color: Colors.transparent,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 100,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: InkWell(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(40),
                          bottomRight: Radius.circular(40),
                        ),
                        onTap: () {
                          if (isOngoing) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookingScreen(
                                  destination: {
                                    "id": order.destinationId,
                                    "image": order.destinationImage ?? "",
                                    "location": order.location,
                                    "name": order.destinationName,
                                    "title": order.destinationName,
                                    "price_per_person": order.destinationPrice ~/ order.peopleCount, // price x person
                                  },
                                  transportation: {
                                    "icon": "assets/icons/transportation/car.svg",
                                    "name": "Car",
                                    "estimation": "3 days",
                                    "price": order.transportPrice,
                                  },
                                  travelDate: DateTime.parse(order.startDate),
                                  returnDate: DateTime.parse(order.endDate),
                                  guestCount: order.peopleCount,
                                  isViewOnly: true,
                                  selectedPaymentMethod: order.paymentMethodName,
                                ),
                              ),
                            );
                          } else {
                            _navigateToDetailDestination(order);
                          }
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFFEDEDED),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(40),
                              bottomRight: Radius.circular(40),
                            ),
                          ),
                          alignment: !isOngoing && (order.statusName.toLowerCase() == "canceled" || order.statusName.toLowerCase() == "rejected")
                              ? Alignment.bottomCenter
                              : Alignment.bottomLeft,
                          padding: !isOngoing && (order.statusName.toLowerCase() == "canceled" || order.statusName.toLowerCase() == "rejected")
                              ? const EdgeInsets.only(bottom: 22)
                              : const EdgeInsets.only(left: 64, bottom: 22),
                          child: Text(
                            isOngoing ? "Detail Booking" : "Booking Again",
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),

                    if (!isOngoing && order.statusName.toLowerCase() != "canceled" && order.statusName.toLowerCase() != "rejected")
                      Positioned(
                        right: 0,
                        bottom: 0,
                        width:
                            MediaQuery.of(context).size.width *
                            0.47, // 50% width
                        child: InkWell(
                          borderRadius: const BorderRadius.only(
                            bottomRight: Radius.circular(40),
                            bottomLeft: Radius.circular(40),
                          ),
                          onTap: () async {
                            final pricePerPerson = order.peopleCount > 0 
                                ? order.destinationPrice ~/ order.peopleCount 
                                : 0;
                            
                            final transportPriceFormatted = "Rp. ${order.transportPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
                            
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReviewScreen(
                                  destination: {
                                    "id": order.bookingId,
                                    "destination_id": order.destinationId,
                                    "image": order.destinationImage ?? "",
                                    "location": order.location,
                                    "name": order.destinationName,
                                    "title": order.destinationName,
                                    "price_per_person": pricePerPerson,
                                  },
                                  transportation: {
                                    "icon": "assets/icons/transportation/car.svg",
                                    "name": "Car",
                                    "estimation": "4 Hari Perjalanan",
                                    "price": transportPriceFormatted,
                                    "transport_price": order.transportPrice,
                                  },
                                  travelDate: DateTime.parse(order.startDate),
                                  returnDate: DateTime.parse(order.endDate),
                                  guestCount: order.peopleCount,
                                  selectedPaymentMethod: order.paymentMethodName,
                                  destinationPrice: order.destinationPrice,
                                  transportPrice: order.transportPrice,
                                  userName: "",
                                ),
                              ),
                            );
                          },
                          child: Container(
                            height: 100,
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 49, 53, 54),
                              borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(40),
                                bottomLeft: Radius.circular(40),
                              ),
                            ),
                            alignment: Alignment.bottomCenter,
                            padding: const EdgeInsets.only(bottom: 22),
                            child: Text(
                              "Review",
                              style: GoogleFonts.roboto(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (isOngoing)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        width:
                            MediaQuery.of(context).size.width *
                            0.47, // 50% width
                        child: InkWell(
                          borderRadius: const BorderRadius.only(
                            bottomRight: Radius.circular(40),
                            bottomLeft: Radius.circular(40),
                          ),
                          onTap: () async {
                            _handleCancelBooking(order.bookingId);
                          },
                          child: Container(
                            height: 100,
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 49, 53, 54),
                              borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(40),
                                bottomLeft: Radius.circular(40),
                              ),
                            ),
                            alignment: Alignment.bottomCenter,
                            padding: const EdgeInsets.only(bottom: 22),
                            child: Text(
                              "Cancel Booking",
                              style: GoogleFonts.roboto(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 220,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: imageUrl != null
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Center(
                                child: Icon(Icons.image_not_supported, size: 50),
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey[300],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.image_not_supported, size: 50),
                          ),
                        ),
                ),
              ),
            ),

            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                            order.statusName,
                  style: GoogleFonts.roboto(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                              color: statusColor,
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: 80,
              left: 30,
              right: 30,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            order.location,
                            style: GoogleFonts.roboto(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        Text(
                          "${order.peopleCount} orang",
                          style: GoogleFonts.roboto(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            order.destinationName,
                            style: GoogleFonts.roboto(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Text(
                          priceFormatted,
                          style: GoogleFonts.roboto(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomNavIndex,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const HomeScreen(),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const DestinationScreen(),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => const ProfileScreen(),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          } else {
            setState(() {
              _currentBottomNavIndex = index;
            });
          }
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Text(
                "My Order",
                style: GoogleFonts.roboto(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            TabBar(
              controller: _tabController,
              labelColor: AppColors.textPrimary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelStyle: GoogleFonts.roboto(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: GoogleFonts.roboto(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              tabs: const [
                Tab(text: "On Going"),
                Tab(text: "History"),
              ],
            ),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                controller: _tabController,
                children: [
                        _ongoingOrders.isEmpty
                      ? Center(
                          child: Text(
                            "No ongoing orders",
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(24),
                                itemCount: _ongoingOrders.length,
                          itemBuilder: (context, index) {
                            return _buildOrderCard(
                                    _ongoingOrders[index],
                              isOngoing: true,
                            );
                          },
                        ),
                  _historyOrders.isEmpty
                      ? Center(
                          child: Text(
                            "No order history",
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(24),
                                itemCount: _historyOrders.length,
                          itemBuilder: (context, index) {
                                  return _buildOrderCard(_historyOrders[index]);
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
