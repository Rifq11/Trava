import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../utils/api_config.dart';
import '../../services/transportation_service.dart';
import '../../services/review_service.dart';
import '../../models/transportation_model.dart';
import '../booking/choose_transportation_dialog.dart';

class DetailDestinationScreen extends StatefulWidget {
  final Map<String, dynamic> destination;

  const DetailDestinationScreen({super.key, required this.destination});

  @override
  State<DetailDestinationScreen> createState() =>
      _DetailDestinationScreenState();
}

class _DetailDestinationScreenState extends State<DetailDestinationScreen> {
  int _guestCount = 1;
  bool _isLoadingTransportations = false;
  bool _isLoadingRating = false;
  List<Transportation> _transportations = [];
  double _averageRating = 0.0;

  @override
  void initState() {
    super.initState();
    _loadTransportations();
    _loadRating();
  }

  Future<void> _loadTransportations() async {
    setState(() {
      _isLoadingTransportations = true;
    });

    try {
      final destinationId = widget.destination['id'] as int?;
      if (destinationId != null) {
        final transportations =
            await TransportationService.getTransportationsByDestination(
              destinationId,
            );
        setState(() {
          _transportations = transportations;
          _isLoadingTransportations = false;
        });
      } else {
        setState(() {
          _isLoadingTransportations = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingTransportations = false;
        });
      }
    }
  }

  Future<void> _loadRating() async {
    setState(() {
      _isLoadingRating = true;
    });

    try {
      final destinationId = widget.destination['id'] as int?;
      if (destinationId != null) {
        final reviews = await ReviewService.getDestinationReviews(
          destinationId,
        );
        if (reviews.isNotEmpty) {
          final totalRating = reviews.fold<double>(
            0.0,
            (sum, review) => sum + review.rating,
          );
          setState(() {
            _averageRating = totalRating / reviews.length;
            _isLoadingRating = false;
          });
        } else {
          setState(() {
            _averageRating = 0.0;
            _isLoadingRating = false;
          });
        }
      } else {
        setState(() {
          _averageRating = 0.0;
          _isLoadingRating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _averageRating = 0.0;
          _isLoadingRating = false;
        });
      }
    }
  }

  String _getTransportationIcon(int transportTypeId) {
    switch (transportTypeId) {
      case 1:
        return "assets/icons/transportation/car.svg";
      case 2:
        return "assets/icons/transportation/bus.svg";
      case 3:
        return "assets/icons/transportation/plane.svg";
      case 4:
        return "assets/icons/transportation/ship.svg";
      default:
        return "assets/icons/transportation/car.svg";
    }
  }

  String _getTransportationName(int transportTypeId) {
    switch (transportTypeId) {
      case 1:
        return "Car";
      case 2:
        return "Bus";
      case 3:
        return "Airplane";
      case 4:
        return "Ship";
      default:
        return "Car";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 400,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50),
                    ),
                    color: Colors.grey[300],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50),
                    ),
                    child:
                        widget.destination["image"] != null &&
                            widget.destination["image"].toString().isNotEmpty
                        ? Image.network(
                            '${ApiConfig.baseUrl.replaceAll('/api', '')}${widget.destination["image"]}',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    size: 50,
                                  ),
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
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 32,
                  left: 24,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: SvgPicture.asset(
                      "assets/icons/arrow_while_back.svg",
                      width: 34,
                      height: 34,
                    ),
                  ),
                ),
                Positioned(
                  top: 32,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "Detail",
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.destination["category"] ?? "Beach",
                              style: GoogleFonts.roboto(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
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
                                  _isLoadingRating
                                      ? "..."
                                      : _averageRating.toStringAsFixed(1),
                                  style: GoogleFonts.roboto(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Text(
                        widget.destination["location"] ?? "Bali, Indonesia",
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              widget.destination["name"] ??
                                  widget.destination["title"] ??
                                  "",
                              style: GoogleFonts.roboto(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            widget.destination["price_per_person"] != null
                                ? "Rp. ${widget.destination["price_per_person"].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} /person"
                                : widget.destination["price"] ?? "",
                            style: GoogleFonts.roboto(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      Text(
                        "Description",
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        widget.destination["description"] ?? "",
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 24),

                      Text(
                        "Transportation",
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 16),

                      _isLoadingTransportations
                          ? const Center(child: CircularProgressIndicator())
                          : _transportations.isEmpty
                          ? const Center(
                              child: Text(
                                'No transportation available',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            )
                          : GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 3,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 2.5,
                              children: _transportations.map((transport) {
                                return _buildTransportationItem(
                                  _getTransportationIcon(
                                    transport.transportTypeId,
                                  ),
                                  _getTransportationName(
                                    transport.transportTypeId,
                                  ),
                                );
                              }).toList(),
                            ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.background,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => ChooseTransportationDialog(
                        destination: widget.destination,
                        guestCount: _guestCount,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Book Now",
                    style: GoogleFonts.roboto(
                      fontSize: 16,
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
    );
  }

  Widget _buildTransportationItem(String iconPath, String name) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(iconPath, width: 24, height: 24),
          const SizedBox(width: 12),
          Text(
            name,
            style: GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
