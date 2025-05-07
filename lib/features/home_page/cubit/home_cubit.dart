import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

import '../../../base/constant/app_images.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  final PageController _pageController = PageController();
  final List<String> _sliderImages = [
    AppAssetImages.photoDoctor1,
    AppAssetImages.photoDoctor1,
  ];
  Timer? _timer;

  PageController get pageController => _pageController;
  List<String> get sliderImages => _sliderImages;

  void onPageChanged(int index) {
    if (state is HomeLoaded) {}
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (state is HomeLoaded) {
        int currentImage = (state as HomeLoaded).currentImage;
        int nextImage = (currentImage + 1) % _sliderImages.length;
        _pageController.animateToPage(
          nextImage,
          duration: Duration(milliseconds: 500),
          curve: Curves.ease,
        );
      }
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _pageController.dispose();
    return super.close();
  }
}
