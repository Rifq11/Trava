import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/trava_logo.dart';
import '../theme/app_colors.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../utils/storage_service.dart';
import 'preview_screen.dart';
import 'auth/login_screen.dart';
import 'home/home_screen.dart';
import 'profile/complete_profile_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _timer = Timer(const Duration(seconds: 2), () {
        if (!mounted) return;
        _navigateToNextScreen();
      });
    });
  }

  Future<void> _navigateToNextScreen() async {
    if (!mounted) return;

    // login check
    final isLoggedIn = await AuthService.isLoggedIn();
    
    if (isLoggedIn) {
      bool isProfileComplete = false;
      try {
        final profile = await ProfileService.getProfile();
        isProfileComplete = profile.profile != null &&
            profile.profile!.phone.isNotEmpty &&
            profile.profile!.address.isNotEmpty &&
            profile.profile!.birthDate.isNotEmpty;
      } catch (e) {
        isProfileComplete = false;
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 700),
          pageBuilder: (_, animation, __) => isProfileComplete
              ? const HomeScreen()
              : const CompleteProfileScreen(),
          transitionsBuilder: (_, animation, __, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            );

            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(2.0, 0.0),
                end: Offset.zero,
              ).animate(curved),
              child: child,
              transformHitTests: false,
            );
          },
        ),
      );
    } else {
      final isFirstLaunch = await StorageService.isFirstLaunch();
      
      if (!mounted) return;

      if (isFirstLaunch) {
        await StorageService.setFirstLaunchComplete();
        
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 700),
            pageBuilder: (_, animation, __) => const PreviewScreen(),
            transitionsBuilder: (_, animation, __, child) {
              final curved = CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOutCubic,
              );

              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(2.0, 0.0),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
                transformHitTests: false,
              );
            },
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 700),
            pageBuilder: (_, animation, __) => const LoginScreen(),
            transitionsBuilder: (_, animation, __, child) {
              final curved = CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOutCubic,
              );

              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(2.0, 0.0),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
                transformHitTests: false,
              );
            },
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: TravaLogo.size(size: 70),
        ),
      ),
    );
  }
}
