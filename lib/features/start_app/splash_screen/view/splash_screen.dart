import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../base/constant/app_images.dart';
import '../../../../base/constant/storage_key.dart';
import '../../../../base/go_router/go_router.dart';
import '../../../../base/services/di/injection_container_common.dart';
import '../../../../base/services/storage/storage_service.dart';
import '../../../../base/theme/app_color.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0;
  bool _isFirstLaunch = true; // Assume it's the first launch initially

  Future<void> _checkFirstLaunch() async {
    final storageService = serviceLocator<StorageService>();
    final isFirst =
        await storageService.getFromDisk(StorageKey.firstInstall) ?? true;
    setState(() {
      _isFirstLaunch = isFirst;
    });
    // If it's the first launch, we'll start the timer in initState.
    // If not, we navigate immediately.
  }

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _opacity = 1.0;
      });
    }).then((_) {
      Future.delayed(const Duration(seconds: 5), () {
        if (_isFirstLaunch) {
          context.goNamed(AppRouter.onBoarding.name);
        } else {
          context.goNamed(AppRouter.welcomeScreen.name);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backGroundLogo,
      body: Center(
        child: Row(
          spacing: 10,
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
                    TextSpan(
                      text: 'edi',
                      style: TextStyle(color: Colors.white),
                    ),
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

            AnimatedOpacity(
              opacity: _opacity,
              duration: const Duration(seconds: 4),
              curve: Curves.easeInOutSine,
              child: SizedBox(
                width: 30,
                height: 30,
                child: Image(
                  image: AssetImage(AppAssetImages.logoGreenPng),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
