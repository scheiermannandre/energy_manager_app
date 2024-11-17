import 'package:energy_manager_app/foundation/foundation.dart';
import 'package:flutter/material.dart';

extension ThemeModeExtension on ThemeMode {
  String get displayName {
    switch (this) {
      case ThemeMode.system:
        return 'System'.hardCoded;
      case ThemeMode.light:
        return 'Light'.hardCoded;
      case ThemeMode.dark:
        return 'Dark'.hardCoded;
    }
  }
}
