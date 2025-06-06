import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medi_zen_app_doctor/base/constant/app_images.dart';
import 'package:medi_zen_app_doctor/base/constant/storage_key.dart';
import 'package:medi_zen_app_doctor/base/go_router/go_router.dart';
import 'package:medi_zen_app_doctor/base/services/di/injection_container_common.dart';
import 'package:medi_zen_app_doctor/base/services/storage/storage_service.dart';
import 'package:medi_zen_app_doctor/base/theme/app_color.dart';

import '../../../../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0;
  bool _isFirstLaunch = true;

  Timer? _navigationTimer;

  Future<void> _checkFirstLaunchAndPatient() async {
    final isFirst = serviceLocator<StorageService>().getFromDisk(StorageKey.firstInstall) ?? true;

    if (mounted) {
      setState(() {
        _isFirstLaunch = isFirst;
      });
    }
  }

  void _navigate() {
    if (!mounted) return;

    if (_isFirstLaunch) {
      context.goNamed(AppRouter.onBoarding.name);
    } else {
      if (token != null) {
        context.goNamed(AppRouter.homePage.name);
      } else {
        context.goNamed(AppRouter.login.name);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _checkFirstLaunchAndPatient();

    // Fade-in animation
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _opacity = 1.0;
        });
      }
    });

    // Navigation timer
    _navigationTimer = Timer(const Duration(seconds: 5), _navigate);
  }

  @override
  void dispose() {
    _navigationTimer?.cancel(); // Cancel the timer to prevent callbacks after unmount
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backGroundLogo,
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedOpacity(
              opacity: _opacity,
              duration: const Duration(seconds: 4),
              curve: Curves.easeInOutSine,
              child: RichText(
                text: TextSpan(
                  text: 'M',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                    fontFamily: 'ChypreNorm',
                  ),
                  children: <TextSpan>[
                    TextSpan(text: 'edi', style: TextStyle(color: Colors.white)),
                    TextSpan(
                      text: 'Z',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(text: 'en', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            AnimatedOpacity(
              opacity: _opacity,
              duration: const Duration(seconds: 4),
              curve: Curves.easeInOutSine,
              child: SizedBox(
                width: 30,
                height: 30,
                child: Image.asset(AppAssetImages.logoGreenPng, fit: BoxFit.fill),
              ),
            ),
          ],
        ),
      ),
    );
  }
}