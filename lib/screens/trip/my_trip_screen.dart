import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../widgets/bottom_bar/custom_bottom_bar.dart';
import '../home/home_screen.dart';
import '../destination/destination_screen.dart';
import '../booking/booking_screen.dart';
import '../destination/detail_destination_screen.dart';
import '../booking/review_screen.dart';
import '../profile/profile_screen.dart';

class MyTripScreen extends StatefulWidget {
  const MyTripScreen({super.key});

  @override
  State<MyTripScreen> createState() => _MyTripScreenState();
}

class _MyTripScreenState extends State<MyTripScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentBottomNavIndex = 2; // 2 = My Trip

  final List<Map<String, dynamic>> ongoingOrders = [
    {
      "id": 1,
      "image": "assets/images/preview_1.png",
      "location": "Bali, Indonesia",
      "title": "Nusa Penida",
      "guests": 2,
      "price": "Rp. 1.200.000",
      "status": "Pending",
      "statusColor": Colors.orange,
    },
    {
      "id": 2,
      "image": "assets/images/preview_2.png",
      "location": "Jawa Tengah, Indonesia",
      "title": "Gunung Bromo",
      "guests": 3,
      "price": "Rp. 1.500.000",
      "status": "Pending",
      "statusColor": Colors.orange,
    },
  ];

  final List<Map<String, dynamic>> historyOrders = [
    {
      "id": 1,
      "image": "assets/images/preview_1.png",
      "location": "Bali, Indonesia",
      "title": "Nusa Penida",
      "guests": 2,
      "price": "Rp. 1.200.000",
      "status": "Canceled",
      "statusColor": Colors.black,
    },
    {
      "id": 2,
      "image": "assets/images/preview_2.png",
      "location": "Bali, Indonesia",
      "title": "Nusa Penida",
      "guests": 2,
      "price": "Rp. 1.200.000",
      "status": "Completed",
      "statusColor": Colors.blue,
    },
    {
      "id": 3,
      "image": "assets/images/preview_3.png",
      "location": "Bali, Indonesia",
      "title": "Nusa Penida",
      "guests": 2,
      "price": "Rp. 1.200.000",
      "status": "Completed",
      "statusColor": Colors.blue,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildOrderCard(Map<String, dynamic> order, {bool isOngoing = false}) {
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
                                    "image": order["image"],
                                    "location": order["location"],
                                    "title": order["title"],
                                    "rating": "4.9",
                                    "price": order["price"],
                                  },
                                  transportation: {
                                    "icon":
                                        "assets/icons/transportation/car.svg",
                                    "name": "Car",
                                    "estimation": "3 days",
                                    "price": "Rp. 1.000.000",
                                  },
                                  travelDate: DateTime.now().add(
                                    const Duration(days: 7),
                                  ),
                                  returnDate: DateTime.now().add(
                                    const Duration(days: 14),
                                  ),
                                  guestCount: order["guests"],
                                  isViewOnly: true,
                                  selectedPaymentMethod: "Credit Card", // TODO: Get from API
                                ),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailDestinationScreen(
                                  destination: {
                                    "image": order["image"],
                                    "location": order["location"],
                                    "title": order["title"],
                                    "rating": "4.9",
                                    "price": order["price"],
                                    "description":
                                        "Beautiful destination with amazing views",
                                  },
                                ),
                              ),
                            );
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
                          alignment: !isOngoing && order["status"] == "Canceled"
                              ? Alignment.bottomCenter
                              : Alignment.bottomLeft,
                          padding: !isOngoing && order["status"] == "Canceled"
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

                    if (!isOngoing && order["status"] != "Canceled")
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
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReviewScreen(
                                  destination: {
                                    "image": order["image"],
                                    "location": order["location"],
                                    "title": order["title"],
                                    "rating": "4.9",
                                    "price": order["price"],
                                  },
                                  transportation: {
                                    "icon":
                                        "assets/icons/transportation/car.svg",
                                    "name": "Car",
                                    "estimation": "4 Hari Perjalanan",
                                    "price": "Rp. 1.000.000",
                                  },
                                  travelDate: DateTime.now().add(
                                    const Duration(days: 7),
                                  ),
                                  returnDate: DateTime.now().add(
                                    const Duration(days: 14),
                                  ),
                                  guestCount: order["guests"],
                                  selectedPaymentMethod: "Transfer Bank",
                                  userName: "Salmah Nadya Safitri",
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
                          onTap: () {
                            // TODO: Handle Cancel Booking
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
                  child: Image.asset(order["image"], fit: BoxFit.cover),
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
                  order["status"],
                  style: GoogleFonts.roboto(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: order["statusColor"],
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
                            order["location"],
                            style: GoogleFonts.roboto(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        Text(
                          "${order["guests"]} orang",
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
                            order["title"],
                            style: GoogleFonts.roboto(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Text(
                          order["price"],
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
              child: TabBarView(
                controller: _tabController,
                children: [
                  ongoingOrders.isEmpty
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
                          itemCount: ongoingOrders.length,
                          itemBuilder: (context, index) {
                            return _buildOrderCard(
                              ongoingOrders[index],
                              isOngoing: true,
                            );
                          },
                        ),

                  historyOrders.isEmpty
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
                          itemCount: historyOrders.length,
                          itemBuilder: (context, index) {
                            return _buildOrderCard(historyOrders[index]);
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
