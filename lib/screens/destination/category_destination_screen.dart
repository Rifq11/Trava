import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../services/destination_service.dart';
import '../../services/review_service.dart';
import '../../models/destination_model.dart';
import '../../utils/api_config.dart';
import 'detail_destination_screen.dart';
import 'search_screen.dart';

class CategoryDestinationScreen extends StatefulWidget {
  final String category;
  final int? categoryId;
  final String? categoryCount;

  const CategoryDestinationScreen({
    super.key,
    required this.category,
    this.categoryId,
    this.categoryCount,
  });

  @override
  State<CategoryDestinationScreen> createState() =>
      _CategoryDestinationScreenState();
}

class _CategoryDestinationScreenState extends State<CategoryDestinationScreen> {
  bool _isLoading = false;
  List<Destination> _destinations = [];
  Map<int, double> _destinationRatings = {};
  final _formatter = NumberFormat('#,###', 'id_ID');

  @override
  void initState() {
    super.initState();
    if (widget.categoryId != null) {
      _loadDestinations();
    }
  }

  Future<void> _loadDestinations() async {
    setState(() => _isLoading = true);

    try {
      final destinations = await DestinationService.getDestinationsByCategory(
        widget.categoryId,
      );
      setState(() {
        _destinations = destinations;
        _isLoading = false;
      });

      _loadRatingsForDestinations(destinations);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
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
        ratingsMap[destination.id] = reviews.isEmpty
            ? 0.0
            : reviews.fold<double>(0.0, (sum, r) => sum + r.rating) /
                  reviews.length;
      } catch (e) {
        ratingsMap[destination.id] = 0.0;
      }
    }

    if (mounted) {
      setState(() {
        _destinationRatings = ratingsMap;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
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
                          height: 34,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          widget.category,
                          style: GoogleFonts.roboto(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SearchScreen(
                          categoryId: widget.categoryId,
                          category: widget.category,
                        ),
                      ),
                    );
                  },
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
                  "Search Result",
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              _isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : _destinations.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: Text("No destinations available")),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: _destinations.map((destination) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _buildCard(destination),
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

  Widget _buildCard(Destination destination) {
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
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                '${ApiConfig.baseUrl.replaceAll('/api', '')}${destination.image}',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                    destination.location,
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Rp ${_formatter.format(destination.pricePerPerson)} /person",
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
