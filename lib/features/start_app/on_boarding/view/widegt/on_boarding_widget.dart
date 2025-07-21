import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
import 'package:medi_zen_app_doctor/base/extensions/media_query_extension.dart';

import '../../../../../base/constant/app_images.dart';
import '../../../../../base/constant/storage_key.dart';
import '../../../../../base/go_router/go_router.dart';
import '../../../../../base/services/di/injection_container_common.dart';
import '../../../../../base/services/storage/storage_service.dart';
import '../../../../../base/theme/app_color.dart';

class OnBoardingWidget extends StatefulWidget {
  const OnBoardingWidget({super.key});

  @override
  State<OnBoardingWidget> createState() => _OnBoardingWidgetState();
}

class _OnBoardingWidgetState extends State<OnBoardingWidget> {
  final PageController _pageController = PageController(initialPage: 0);
  Timer? _timer;
  int currentPage = 0;

  final List<String> _imagePaths = [
    AppAssetImages.photoDoctor8,
    AppAssetImages.photoDoctor4,
    AppAssetImages.photoDoctor9,
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 7), (timer) async {
      if (currentPage < _imagePaths.length - 1) {
        currentPage++;
        _pageController.animateToPage(
          currentPage,
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeInOut,
        );
      } else {
        timer.cancel();
        await serviceLocator<StorageService>();
        StorageKey.firstInstall;

        if (mounted) {
          context.goNamed(AppRouter.welcomeScreen.name);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<String> titles = [
      "on_boarding.manage_medical_records".tr(context),
      "on_boarding.track_your_health".tr(context),
      "on_boarding.medicine_reminder".tr(context),
    ];
    final List<String> description = [
      "on_boarding.keep_all_your_medical".tr(context),
      "on_boarding.easily_track_health".tr(context),
      "on_boarding.set_up_reminder".tr(context),
    ];
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Center(
                    child: SizedBox(
                      height: context.height / 1.99,
                      width: context.width,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _imagePaths.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(
                              _imagePaths[index],
                              fit: BoxFit.fitHeight,
                            ),
                          );
                        },
                        onPageChanged: (index) {
                          setState(() {
                            currentPage = index;
                          });
                        },
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: -90.0,
                    left: 0,
                    right: 0,
                    child: Container(
                      width: context.width,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).secondaryHeaderColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            titles[currentPage],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                          Text(
                            description[currentPage],
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ), //
              Gap(200),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_imagePaths.length, (index) {
                        return InkWell(
                          onTap: () {
                            _pageController.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Container(
                            width: 10,
                            height: 5,
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              color:
                                  currentPage == index
                                      ? Theme.of(context).primaryColor
                                      : AppColors.greyColor,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  SizedBox(width: 70),
                  GestureDetector(
                    onTap: () async {
                      _timer?.cancel();
                      await serviceLocator<StorageService>();
                      StorageKey.firstInstall;

                      if (mounted) {
                        context.pushNamed(AppRouter.login.name);
                      }
                    },

                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(100),
                        color: Theme.of(context).primaryColor,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.arrow_forward_sharp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Gap(10),
            ],
          ),
        ),
      ),
    );
  }
}
