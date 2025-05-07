import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';

import '../theme.dart';

enum _Variant {
  icon,
  outlined,
}

class ThemeModeButton extends StatelessWidget {
  const ThemeModeButton._(this.variant);

  const ThemeModeButton.icon() : this._(_Variant.icon);

  const ThemeModeButton.outlined() : this._(_Variant.outlined);

  // ignore: library_private_types_in_public_api
  final _Variant variant;

  @override
  Widget build(BuildContext context) {
    return ThemeSwitcher.withTheme(
      builder: (_, switcher, theme) {
        return IconButton(
          onPressed: () => switcher.changeTheme(
            theme: theme.brightness == Brightness.light ? darkTheme : lightTheme,
          ),
          icon: Icon(theme.brightness == Brightness.light ? Icons.brightness_3 : Icons.brightness_5, size: 25,color: Theme.of(context).primaryColor,),
        );
      },
    );

  }
}
