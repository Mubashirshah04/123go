import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppThemes {
  static ThemeData get lightTheme => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F6F8),
        useMaterial3: true,
      );

  static ThemeData get darkTheme => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      );
}

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);