import 'dart:async';
import 'package:flutter/material.dart';
import 'preview_screen.dart';
import '../widgets/trava_logo.dart';
import '../theme/app_colors.dart';

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
      });
    });
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
