import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../widgets/bottom_bar/custom_bottom_bar.dart';
import '../../services/destination_service.dart';
import '../../services/profile_service.dart';
import '../../services/review_service.dart';
import '../../models/destination_model.dart';
import '../../utils/api_config.dart';
import '../../utils/storage_service.dart';
import '../destination/destination_screen.dart';
import '../destination/search_screen.dart';
import '../destination/detail_destination_screen.dart';
import '../trip/my_trip_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentSlider = 0;
  int _selectedCategory = 0;
  int _currentBottomNavIndex = 0;
  bool _isLoading = false;
  bool _isLoadingCategories = false;

  List<DestinationCategory> _categories = [];
  List<Destination> _upcomingTours = []; // carousel - get all max 10
  List<Destination> _filteredDestinations = [];
  String _userName = "";
  Map<int, double> _destinationRatings = {};

  final formatter = NumberFormat('#,###', 'id_ID');

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadUpcomingTours();
    _loadCategories(); // default index = 0
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await ProfileService.getProfile();
      setState(() => _userName = profile.user.fullName);
    } catch (e) {
      final userData = await StorageService.getUserData();
      if (userData != null) {
        setState(() => _userName = userData['name'] ?? '');
      }
    }
  }

  Future<void> _loadUpcomingTours() async {
    try {
      final allDestinations =
          await DestinationService.getDestinations();
      final topTen = allDestinations.take(10).toList();

      setState(() {
        _upcomingTours = topTen;
      });

      _loadRatingsForDestinations(topTen);
    } catch (e) {
      debugPrint("Error load upcoming: $e");
    }
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoadingCategories = true);

    try {
      final categories = await DestinationService.getCategories();
      setState(() {
        _categories = categories;
        _isLoadingCategories = false;
      });

      if (_categories.isNotEmpty) {
        _onCategorySelected(0);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingCategories = false);
    }
  }

  Future<void> _loadDestinations({int? categoryId}) async {
    setState(() => _isLoading = true);

    try {
      final destinations = await DestinationService.getDestinationsByCategory(
        categoryId,
      );

      setState(() {
        _filteredDestinations = destinations;
        _isLoading = false;
      });

      _loadRatingsForDestinations(destinations);
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadRatingsForDestinations(
    List<Destination> destinations,
  ) async {
    final ratingsMap = <int, double>{};

    for (var destination in destinations) {
      try {
        final reviews = await ReviewService.getDestinationReviews(
          destination.id,
        );

        if (reviews.isNotEmpty) {
          final totalRating = reviews.fold<double>(
            0.0,
            (sum, review) => sum + review.rating,
          );
          ratingsMap[destination.id] = totalRating / reviews.length;
        } else {
          ratingsMap[destination.id] = 0.0;
        }
      } catch (e) {
        ratingsMap[destination.id] = 0.0;
      }
    }

    if (mounted) setState(() => _destinationRatings = ratingsMap);
  }

  void _onCategorySelected(int index) {
    setState(() => _selectedCategory = index);
    final category = _categories[index];
    _loadDestinations(categoryId: category.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomNavIndex,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const DestinationScreen(),
              ),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const MyTripScreen(),
              ),
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const ProfileScreen(),
              ),
            );
          } else {
            setState(() => _currentBottomNavIndex = index);
          }
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 56),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Halo,\n${_userName.isNotEmpty ? _userName : 'User'}!",
                      style: GoogleFonts.roboto(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SearchScreen()),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.surface,
                        ),
                        child: const Icon(Icons.search, size: 24),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    Text(
                      "Upcoming Tour",
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              _upcomingTours.isEmpty
                  ? const SizedBox(
                      height: 215,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : CarouselSlider.builder(
                      itemCount: _upcomingTours.length,
                      itemBuilder: (_, index, __) =>
                          _buildUpcomingCard(_upcomingTours[index]),
                      options: CarouselOptions(
                        height: 215,
                        autoPlay: true,
                        autoPlayInterval: const Duration(seconds: 4),
                        enlargeCenterPage: true,
                        viewportFraction: 0.85,
                        onPageChanged: (index, reason) =>
                            setState(() => _currentSlider = index),
                      ),
                    ),

              const SizedBox(height: 26),

              SizedBox(
                height: 42,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: _categories.length,
                  itemBuilder: (_, index) {
                    final selected = _selectedCategory == index;
                    return GestureDetector(
                      onTap: () => _onCategorySelected(index),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _categories[index].name,
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: selected
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary.withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(height: 6),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              width: selected ? 36 : 0,
                              height: 3,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: _filteredDestinations.isEmpty
                      ? [
                          const Text(
                            "No destinations found",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ]
                      : _filteredDestinations.take(3).map((destination) {
                          return Column(
                            children: [
                              _buildDestinationCard(destination),
                              const SizedBox(height: 14),
                            ],
                          );
                        }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingCard(Destination destination) {
    final rating = _destinationRatings[destination.id] ?? 0.0;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DetailDestinationScreen(
            destination: {
              'id': destination.id,
              'name': destination.name,
              'description': destination.description,
              'location': destination.location,
              'price_per_person': destination.pricePerPerson,
              'image': destination.image,
            },
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        height: 215,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                "${ApiConfig.baseUrl.replaceAll('/api', '')}${destination.image}",
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            Positioned(
              bottom: 16,
              left: 16,
              right: 144,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      destination.location,
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            destination.name,
                            style: GoogleFonts.roboto(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        SvgPicture.asset(
                          "assets/icons/arrow_next.svg",
                          width: 28,
                          height: 28,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              top: 14,
              right: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      rating.toStringAsFixed(1),
                      style: GoogleFonts.roboto(
                        fontSize: 12,
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
    );
  }

  Widget _buildDestinationCard(Destination destination) {
    final rating = _destinationRatings[destination.id] ?? 0.0;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DetailDestinationScreen(
            destination: {
              'id': destination.id,
              'name': destination.name,
              'description': destination.description,
              'location': destination.location,
              'price_per_person': destination.pricePerPerson,
              'image': destination.image,
            },
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    '${ApiConfig.baseUrl.replaceAll("/api", "")}${destination.image}',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, size: 12, color: Colors.amber),
                        const SizedBox(width: 3),
                        Text(
                          rating.toStringAsFixed(1),
                          style: GoogleFonts.roboto(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 14),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  destination.location,
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  destination.name,
                  style: GoogleFonts.roboto(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  "Rp ${formatter.format(destination.pricePerPerson)} /person",
                  style: GoogleFonts.roboto(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const Spacer(),
            SvgPicture.asset("assets/icons/arrow_next.svg", width: 34),
          ],
        ),
      ),
    );
  }
}
