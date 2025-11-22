import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../widgets/bottom_bar/custom_bottom_bar.dart';
import '../../services/destination_service.dart';
import '../../services/review_service.dart';
import '../../models/destination_model.dart';
import '../../utils/api_config.dart';
import '../home/home_screen.dart';
import 'category_destination_screen.dart';
import 'search_screen.dart';
import 'detail_destination_screen.dart';
import '../trip/my_trip_screen.dart';
import '../profile/profile_screen.dart';

class DestinationScreen extends StatefulWidget {
  const DestinationScreen({super.key});

  @override
  State<DestinationScreen> createState() => _DestinationScreenState();
}

class _DestinationScreenState extends State<DestinationScreen> {
  int _currentBottomNavIndex = 1;
  bool _isLoading = false;
  bool _isLoadingCategories = false;

  List<DestinationCategory> _categories = [];
  List<Destination> _allDestinations = [];
  Map<int, List<Destination>> _destinationsByCategory = {};
  Map<int, double> _destinationRatings = {};

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadDestinations();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoadingCategories = true);

    try {
      final categories = await DestinationService.getCategories();
      setState(() {
        _categories = categories;
        _isLoadingCategories = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoadingCategories = false);
    }
  }

  Future<void> _loadDestinations() async {
    setState(() => _isLoading = true);

    try {
      final destinations = await DestinationService.getDestinations();
      setState(() {
        _allDestinations = destinations;

        _destinationsByCategory.clear();
        for (var destination in destinations) {
          _destinationsByCategory.putIfAbsent(destination.categoryId, () => []);
          _destinationsByCategory[destination.categoryId]!.add(destination);
        }

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
    final map = <int, double>{};

    for (var destination in destinations) {
      try {
        final reviews = await ReviewService.getDestinationReviews(
          destination.id,
        );
        map[destination.id] = reviews.isEmpty
            ? 0.0
            : reviews.fold<double>(0.0, (sum, r) => sum + r.rating) /
                  reviews.length;
      } catch (e) {
        map[destination.id] = 0.0;
      }
    }

    if (mounted) setState(() => _destinationRatings = map);
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
              PageRouteBuilder(pageBuilder: (_, __, ___) => const HomeScreen()),
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
              const SizedBox(height: 24),

              Center(
                child: Text(
                  "Destination",
                  style: GoogleFonts.roboto(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SearchScreen()),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: AppColors.iconGray, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          "Search for your favorite place",
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  "Find Your Favorite Place",
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              _isLoadingCategories
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: _categories.length,
                        itemBuilder: (_, index) {
                          final category = _categories[index];
                          final count =
                              _destinationsByCategory[category.id]?.length ?? 0;
                          return _buildFavoritePlaceCard(category, count);
                        },
                      ),
                    ),

              const SizedBox(height: 32),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  "Search Result",
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: _allDestinations
                            .map(
                              (d) => Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: _buildSearchResultCard(d),
                              ),
                            )
                            .toList(),
                      ),
                    ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFavoritePlaceCard(DestinationCategory category, int count) {
    final list = _destinationsByCategory[category.id] ?? [];
    final img = list.isNotEmpty && list.first.image.isNotEmpty
        ? "${ApiConfig.baseUrl.replaceAll('/api', '')}${list.first.image}"
        : null;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CategoryDestinationScreen(
            category: category.name,
            categoryId: category.id,
          ),
        ),
      ),
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey[300],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: img != null
                  ? Image.network(
                      img,
                      width: 280,
                      height: 200,
                      fit: BoxFit.cover,
                    )
                  : Container(color: Colors.grey[300]),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "$count Destination${count > 1 ? 's' : ''}",
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category.name,
                    style: GoogleFonts.roboto(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SvgPicture.asset("assets/icons/arrow_next.svg", width: 34),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultCard(Destination destination) {
    final category = _categories.firstWhere(
      (c) => c.id == destination.categoryId,
      orElse: () => DestinationCategory(id: 0, name: ""),
    );

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
                    "${ApiConfig.baseUrl.replaceAll('/api', '')}${destination.image}",
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                if (category.name.isNotEmpty)
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        category.name,
                        style: GoogleFonts.roboto(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 12),
                        const SizedBox(width: 2),
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

            Expanded(
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
                  const SizedBox(height: 2),
                  Text(
                    destination.name,
                    style: GoogleFonts.roboto(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Rp ${NumberFormat('#,###', 'id_ID').format(destination.pricePerPerson)} /person",
                    style: GoogleFonts.roboto(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            SvgPicture.asset("assets/icons/arrow_next.svg", width: 34),
          ],
        ),
      ),
    );
  }
}
