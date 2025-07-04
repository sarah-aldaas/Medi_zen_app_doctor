import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medi_zen_app_doctor/base/extensions/media_query_extension.dart';
import 'package:medi_zen_app_doctor/base/widgets/show_toast.dart';

import '../services/di/injection_container_common.dart';
import '../services/network/network_info.dart';

class NoInternetPage extends StatefulWidget {
  const NoInternetPage({super.key});

  @override
  State<NoInternetPage> createState() => _NoInternetPageState();
}

class _NoInternetPageState extends State<NoInternetPage> {
  final networkInfo = serviceLocator<NetworkInfo>();

  Future<void> _handleRefresh() async {
    final isConnected = await networkInfo.isConnected;
    if (isConnected) {
      context.pop(); // Navigate back to previous screen
    } else {
      ShowToast.showToastError(message: 'Still no internet connection');
    }
    // Optional: Add slight delay to ensure refresh animation is visible
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: Colors.blue, // Customize refresh indicator color
        backgroundColor: Colors.white, // Customize background
        child: SingleChildScrollView(
          // Enable scrolling to allow pull-to-refresh even when content fits
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            width: context.width,
            height: context.height, // Ensure full height for centering
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/images/no_internet.png",
                  fit: BoxFit.contain,
                  height: context.height * 0.4,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No Internet Connection',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please check your network and try again.',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Pull down to refresh',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}