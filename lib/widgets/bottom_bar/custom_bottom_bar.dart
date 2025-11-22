import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/app_colors.dart';

class CustomBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(
            iconIn: 'assets/icons/bottom bar/home_in.svg',
            iconOut: 'assets/icons/bottom bar/home_out.svg',
            index: 0,
          ),
          _buildNavItem(
            iconIn: 'assets/icons/bottom bar/destination_in.svg',
            iconOut: 'assets/icons/bottom bar/destination_out.svg',
            index: 1,
          ),
          _buildNavItem(
            iconIn: 'assets/icons/bottom bar/my_trip_in.svg',
            iconOut: 'assets/icons/bottom bar/my_trip_out.svg',
            index: 2,
          ),
          _buildNavItem(
            iconIn: 'assets/icons/bottom bar/profile_in.svg',
            iconOut: 'assets/icons/bottom bar/profile_out.svg',
            index: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required String iconIn,
    required String iconOut,
    required int index,
  }) {
    final isActive = currentIndex == index;
    final iconFile = isActive ? iconIn : iconOut;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Builder(
        builder: (context) {
          try {
            return SvgPicture.asset(
              iconFile,
              width: 28,
              height: 34,
              fit: BoxFit.contain,
            );
          } catch (e) {
            debugPrint('Error loading icon: $iconFile - $e');
            return Icon(
              index == 0
                  ? Icons.home
                  : index == 1
                      ? Icons.location_on
                      : index == 2
                          ? Icons.card_travel
                          : Icons.person,
              size: 28,
            );
          }
        },
      ),
    );
  }
}

