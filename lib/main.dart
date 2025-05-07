import 'dart:ui';

import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show SystemChrome, SystemUiMode, SystemUiOverlay;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:oktoast/oktoast.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'base/blocs/localization_bloc/localization_bloc.dart';
import 'base/constant/storage_key.dart';
import 'base/go_router/go_router.dart';
import 'base/services/di/injection_container_common.dart';
import 'base/services/di/injection_container_gen.dart';
import 'base/services/localization/app_localization_service.dart';
import 'base/services/storage/storage_service.dart';
import 'base/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  await bootstrapApplication();
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
  );
  runApp(const MyApp());
}

String? token = serviceLocator<StorageService>().getFromDisk(StorageKey.token);

Future<void> bootstrapApplication() async {
  await initDI();
  await DependencyInjectionGen.initDI();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isPlatformDark =
        PlatformDispatcher.instance.platformBrightness == Brightness.dark;
    final initTheme = isPlatformDark ? darkTheme : lightTheme;
    return ThemeProvider(
      initTheme: initTheme,
      duration: const Duration(milliseconds: 500),
      builder:
          (_, theme) => ResponsiveBreakpoints.builder(
            breakpoints: [
              const Breakpoint(start: 0, end: 450, name: MOBILE),
              const Breakpoint(start: 451, end: 960, name: TABLET),
              const Breakpoint(start: 961, end: double.infinity, name: DESKTOP),
            ],
            child: MultiBlocProvider(
              providers: [
                BlocProvider<LocalizationBloc>(
                  create: (context) => serviceLocator<LocalizationBloc>(),
                  lazy: false,
                ),
              ],
              child: BlocBuilder<LocalizationBloc, LocalizationState>(
                builder: (context, state) {
                  return OKToast(
                    child: MaterialApp.router(
                      routerConfig: goRouter(),
                      theme: theme,
                      debugShowCheckedModeBanner: false,
                      title: 'MediZen Mobile',
                      locale: state.locale,
                      supportedLocales: AppLocalizations.supportedLocales,
                      localizationsDelegates: [
                        AppLocalizations.delegate,
                        GlobalWidgetsLocalizations.delegate,
                        GlobalMaterialLocalizations.delegate,
                        GlobalCupertinoLocalizations.delegate,
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
    );
  }
}
