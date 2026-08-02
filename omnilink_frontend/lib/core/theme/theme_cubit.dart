import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

@injectable
class ThemeCubit extends Cubit<ThemeMode> {
  final FlutterSecureStorage _storage;
  static const _themeKey = 'app_theme_mode';

  ThemeCubit(this._storage) : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final savedTheme = await _storage.read(key: _themeKey);
      if (savedTheme != null) {
        if (savedTheme == 'light') {
          emit(ThemeMode.light);
        } else if (savedTheme == 'dark') {
          emit(ThemeMode.dark);
        } else {
          emit(ThemeMode.system);
        }
      } else {
        // Default to dark theme as it was previously
        emit(ThemeMode.dark);
      }
    } catch (_) {
      emit(ThemeMode.dark);
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    try {
      emit(mode);
      String value = 'system';
      if (mode == ThemeMode.light) value = 'light';
      if (mode == ThemeMode.dark) value = 'dark';
      
      await _storage.write(key: _themeKey, value: value);
    } catch (_) {
      // Ignore storage errors
    }
  }

  Future<void> toggleTheme() async {
    if (state == ThemeMode.light) {
      await setTheme(ThemeMode.dark);
    } else {
      await setTheme(ThemeMode.light);
    }
  }
}
