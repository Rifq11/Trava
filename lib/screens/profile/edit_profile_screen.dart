import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_colors.dart';
import '../../widgets/profile_avatar_icon.dart';
import '../../widgets/add_profile_icon.dart';
import '../../services/profile_service.dart';
import '../../models/profile_model.dart';
import '../../widgets/custom_snackbar.dart';
import '../../utils/error_formatter.dart';
import '../../utils/api_config.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  String _currentPhotoUrl = "";
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final profile = await ProfileService.getProfile();
      setState(() {
        _nameController.text = profile.user.fullName;
        _emailController.text = profile.user.email;
        if (profile.profile != null) {
          // YYYY-MM-DD to "DD Month YYYY"
          if (profile.profile!.birthDate.isNotEmpty) {
            try {
              DateTime dateTime;
              if (profile.profile!.birthDate.contains('T') || profile.profile!.birthDate.contains('Z')) {
                dateTime = DateTime.parse(profile.profile!.birthDate);
              } else if (profile.profile!.birthDate.contains('-') && profile.profile!.birthDate.length == 10) {
                final parts = profile.profile!.birthDate.split('-');
                dateTime = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
              } else {
                dateTime = DateTime.parse(profile.profile!.birthDate);
              }
              _birthDateController.text = "${dateTime.day} ${_getMonthName(dateTime.month)} ${dateTime.year}";
            } catch (e) {
              if (profile.profile!.birthDate.contains('T')) {
                try {
                  final datePart = profile.profile!.birthDate.split('T')[0];
                  if (datePart.length == 10) {
                    final parts = datePart.split('-');
                    final dateTime = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
                    _birthDateController.text = "${dateTime.day} ${_getMonthName(dateTime.month)} ${dateTime.year}";
                  } else {
                    _birthDateController.text = '';
                  }
                } catch (e2) {
                  _birthDateController.text = '';
                }
              } else {
                _birthDateController.text = '';
              }
            }
          }
          _phoneController.text = profile.profile!.phone;
          _addressController.text = profile.profile!.address;
          _currentPhotoUrl = profile.profile!.userPhoto;
        }
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        final errorMessage = e.toString().replaceFirst('Exception: ', '');
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
    _nameController.dispose();
    _emailController.dispose();
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
            keyboardType: label == "Phone" ? TextInputType.phone : TextInputType.text,
            inputFormatters: label == "Phone" 
                ? [FilteringTextInputFormatter.digitsOnly]
                : null,
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

  Widget _buildBirthDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Birth Date",
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectBirthDate,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _birthDateController.text.isEmpty
                      ? "Birth Date"
                      : _birthDateController.text,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    color: _birthDateController.text.isEmpty
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                  ),
                ),
                const Icon(
                  Icons.calendar_today,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Future<void> _selectBirthDate() async {
    DateTime? initialDate;
    if (_birthDateController.text.isNotEmpty) {
      try {
        final parts = _birthDateController.text.split(' ');
        if (parts.length == 3) {
          final day = int.parse(parts[0]);
          final month = _getMonthNumber(parts[1]);
          final year = int.parse(parts[2]);
          initialDate = DateTime(year, month, day);
        }
      } catch (e) {
        // If parsing fails, use default
      }
    }
    initialDate ??= DateTime.now().subtract(const Duration(days: 365 * 18));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formattedDate = "${picked.day} ${_getMonthName(picked.month)} ${picked.year}";
      setState(() {
        _birthDateController.text = formattedDate;
      });
    }
  }

  String _getMonthName(int month) {
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
      'December'
    ];
    return months[month - 1];
  }

  int _getMonthNumber(String monthName) {
    const months = {
      'January': 1,
      'February': 2,
      'March': 3,
      'April': 4,
      'May': 5,
      'June': 6,
      'July': 7,
      'August': 8,
      'September': 9,
      'October': 10,
      'November': 11,
      'December': 12
    };
    return months[monthName] ?? 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 24, top: 10),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(3.14159),
                child: SvgPicture.asset(
                  'assets/icons/arrow_next.svg',
                  width: 34,
                  height: 34,
                ),
              ),
            ),
          ),
          title: const Padding(
            padding: EdgeInsets.only(top: 28),
            child: Text(
              "Edit Profile",
              style: TextStyle(
                fontSize: 24,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          centerTitle: true,
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 24),

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
                    child: _selectedImage != null
                        ? ClipOval(
                            child: Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : _currentPhotoUrl.isNotEmpty
                            ? ClipOval(
                                child: Image.network(
                                  '${ApiConfig.baseUrl.replaceAll('/api', '')}$_currentPhotoUrl',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const ProfileAvatarIcon(size: 64);
                                  },
                                ),
                              )
                            : const ProfileAvatarIcon(size: 64),
                  ),
                  if (_selectedImage == null && _currentPhotoUrl.isEmpty)
                    Positioned(
                      bottom: 6,
                      right: 6,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: const AddProfileIcon(size: 36),
                      ),
                    ),
                  if (_selectedImage != null || _currentPhotoUrl.isNotEmpty)
                    Positioned(
                      bottom: 6,
                      right: 6,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.secondary,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 32),

              _buildInputField("Name", "Your Full Name", _nameController),
              _buildInputField("Email", "Your Email", _emailController),
              _buildBirthDateField(),
              _buildInputField("Phone", "Your Phone Number", _phoneController),
              _buildInputField("Address", "Your Address", _addressController, isAddress: true),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: AppColors.textSecondary,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                    "Save",
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

  Future<void> _pickImage() async {
    final option = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  "Select Photo",
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context, ImageSource.camera),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.textSecondary.withOpacity(0.1),
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: AppColors.secondary,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "Camera",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context, ImageSource.gallery),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.textSecondary.withOpacity(0.1),
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.photo_library,
                                  color: AppColors.secondary,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "Gallery",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(
                        color: AppColors.textSecondary.withOpacity(0.2),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );

    if (option != null) {
      final pickedFile = await _picker.pickImage(source: option);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    }
  }

  Future<void> _handleSave() async {
    setState(() {
      _isSaving = true;
    });

    try {
      // YYYY-MM-DD mysql format
      String? formattedBirthDate;
      final birthDateText = _birthDateController.text.trim();
      if (birthDateText.isNotEmpty) {
        try {
          DateTime dateTime;
          
          if (birthDateText.contains('T') || birthDateText.contains('Z')) {
            dateTime = DateTime.parse(birthDateText);
            formattedBirthDate = "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
          } 
          else if (birthDateText.contains('-') && birthDateText.length == 10) {
            final parts = birthDateText.split('-');
            if (parts.length == 3) {
              final year = int.parse(parts[0]);
              final month = int.parse(parts[1]);
              final day = int.parse(parts[2]);
              dateTime = DateTime(year, month, day);
              formattedBirthDate = "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
            }
          }
          else {
            final parts = birthDateText.split(' ');
            if (parts.length == 3) {
              final day = int.parse(parts[0]);
              final month = _getMonthNumber(parts[1]);
              final year = int.parse(parts[2]);
              dateTime = DateTime(year, month, day);
              formattedBirthDate = "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
            }
          }
        } catch (e) {
          formattedBirthDate = null;
        }
      }

      final request = UpdateProfileRequest(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        birthDate: formattedBirthDate,
      );

      // send photo went it's new uplaoded
      File? photoFileToSend;
      if (_selectedImage != null) {
        try {
          if (await _selectedImage!.exists()) {
            photoFileToSend = _selectedImage;
          }
        } catch (e) {
          photoFileToSend = null;
        }
      }

      await ProfileService.updateProfile(
        request,
        photoFile: photoFileToSend,
      );

      if (mounted) {
        showCustomSnackBar(
          context,
          "Profile updated successfully!",
          isSuccess: true,
        );

        await _loadProfile();
        
        setState(() {
          _selectedImage = null;
        });

        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            Navigator.pop(context, true);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = ErrorFormatter.format(e.toString());
        
        if (errorMessage.toLowerCase().contains('file') || 
            errorMessage.toLowerCase().contains('upload') ||
            errorMessage.toLowerCase().contains('image') ||
            errorMessage.toLowerCase().contains('photo')) {
          errorMessage = "Failed to upload photo. Please try again.";
        } else if (errorMessage.toLowerCase().contains('birth_date') || 
                   errorMessage.toLowerCase().contains('date')) {
          errorMessage = "Invalid date format. Please select a valid date.";
        }
        
        showCustomSnackBar(
          context,
          errorMessage,
          isSuccess: false,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}
