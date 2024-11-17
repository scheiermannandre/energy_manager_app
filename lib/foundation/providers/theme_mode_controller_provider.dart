import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_mode_controller_provider.g.dart';

@riverpod
class ThemeModeController extends _$ThemeModeController {
  @override
  ThemeMode build() {
    return ThemeMode.dark;
  }

  // ignore: avoid_setters_without_getters
  set setTheme(ThemeMode themeMode) {
    state = themeMode;
  }
}
