import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import '../../theme/app_colors.dart';
import '../../widgets/profile_avatar_icon.dart';
import '../../widgets/add_profile_icon.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _nameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _birthDateController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Widget _buildInputField(
    String label,
    String hint,
    TextEditingController controller, {
    bool isAddress = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(fontFamily: 'Roboto'),
            maxLines: isAddress ? 4 : 1,
            minLines: isAddress ? 4 : 1,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: AppColors.textSecondary,
                fontFamily: 'Roboto',
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 56),

              const Text(
                "Complete Your Profile",
                style: TextStyle(
                  fontSize: 30,
                  fontFamily: 'SurgenaFont',
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 8),
              const Text(
                "Help us personalize your experience by completing your profile.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 40),

              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 164,
                    height: 164,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade200,
                    ),
                    child: const ProfileAvatarIcon(size: 64),
                  ),
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: () {},
                      child: const AddProfileIcon(size: 36),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              _buildInputField("Name", "Your Full Name", _nameController),
              _buildInputField(
                "Birth Date",
                "Birth Date",
                _birthDateController,
              ),
              _buildInputField("Phone", "Your Phone Number", _phoneController),
              _buildInputField("Address", "Your Address", _addressController, isAddress: true),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 700),
                        pageBuilder: (_, animation, __) => const HomeScreen(),
                        transitionsBuilder: (_, animation, __, child) {
                          final curved = CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeInOutCubic,
                          );

                          final offsetAnimation = Tween<Offset>(
                            begin: const Offset(2.0, 0.0),
                            end: Offset.zero,
                          ).animate(curved);

                          return SlideTransition(
                            position: offsetAnimation,
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Get Started",
                    style: TextStyle(
                      fontFamily: 'Roboto',
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
      ),
    );
  }
}
