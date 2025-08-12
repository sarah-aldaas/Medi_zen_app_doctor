import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'base/constant/storage_key.dart';
import 'base/services/storage/storage_service.dart';
import 'features/notifications/data/models/store_FCM_model.dart';
import 'features/notifications/presentation/cubit/notification_cubit/notification_cubit.dart';

class FCMManager {
  final NotificationCubit notificationCubit;
  final StorageService storageService;

  FCMManager({required this.notificationCubit, required this.storageService});

  Future<void> initialize(BuildContext context) async {
    // Get token if user is logged in
    if (storageService.getFromDisk(StorageKey.tokenFCM) != null) {
      await setupFCMToken(context);
    }

    // Listen for token refreshes
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      if (storageService.getFromDisk(StorageKey.tokenFCM) != null) {
        await _updateFCMToken(newToken, context);
      }
    });

    // Handle background/foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
  }

  Future<void> setupFCMToken(BuildContext context) async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await _updateFCMToken(token, context);
      }
    } catch (e) {
      print('Error getting FCM token: $e');
    }
  }

  Future<void> _updateFCMToken(String token, BuildContext context) async {
    final deviceInfo = DeviceInfoPlugin();
    String deviceName = 'Unknown';
    String platform = 'Unknown';

    if (kIsWeb) {
      platform = 'Web';
      // Web specific device info
    } else if (Platform.isAndroid) {
      platform = 'Android';
      final androidInfo = await deviceInfo.androidInfo;
      deviceName = androidInfo.model;
    } else if (Platform.isIOS) {
      platform = 'iOS';
      final iosInfo = await deviceInfo.iosInfo;
      deviceName = iosInfo.utsname.machine ?? 'iOS Device';
    }

    final model = StoreFCMModel(
      tokenFCM: token,
      platform: platform,
      deviceName: deviceName,
    );

    await notificationCubit.storeFCMToken(model: model, context: context);
  }

  Future<void> deleteToken(BuildContext context) async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      String platform = 'Unknown';

      if (kIsWeb) {
        platform = 'Web';
      } else if (Platform.isAndroid) {
        platform = 'Android';
      } else if (Platform.isIOS) {
        platform = 'iOS';
      }
      final deviceName = await getDeviceName();
      final model = StoreFCMModel(
        tokenFCM: token,
        platform: platform,
        deviceName: deviceName,
      );

      await notificationCubit.deleteFCMToken(model: model, context: context);
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Got a message whilst in the foreground!');
    debugPrint('Message data: ${message.data}');

    if (message.notification != null) {
      debugPrint(
        'Message also contained a notification: ${message.notification}',
      );
    }
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    // Handle when app is opened from background
    debugPrint('Message opened from background: ${message.data}');
    // You might want to navigate to specific screen based on message
  }

  Future<String> getDeviceName() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.model; // e.g. "Pixel 5"
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.utsname.machine ?? 'iOS Device'; // e.g. "iPhone12,1"
    } else if (Platform.isWindows) {
      final windowsInfo = await deviceInfo.windowsInfo;
      return windowsInfo.computerName;
    } else if (Platform.isMacOS) {
      final macInfo = await deviceInfo.macOsInfo;
      return macInfo.computerName;
    } else if (Platform.isLinux) {
      final linuxInfo = await deviceInfo.linuxInfo;
      return linuxInfo.name;
    }

    return 'Unknown Device';
  }
}
