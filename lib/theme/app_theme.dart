// lib/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Ajuste estes HEX para bater com o site
class AppColors {
  static const primary   = Color(0xFFFF6A00); // laranja do projeto
  static const secondary = Color(0xFF1F2A44); // acento 1
  static const tertiary  = Color(0xFF00C2A8); // acento 2

  static const lightSurface    = Colors.white;
  static const lightBackground = Colors.white;

  static const darkSurface     = Color(0xFF0F0F10);
  static const darkBackground  = Color(0xFF0B0B0C);
}

class AppTheme {
  static ColorScheme _brandScheme(Brightness brightness) {
    final base = ColorScheme.fromSeed(seedColor: AppColors.primary, brightness: brightness);
    final sec  = ColorScheme.fromSeed(seedColor: AppColors.secondary, brightness: brightness);
    final ter  = ColorScheme.fromSeed(seedColor: AppColors.tertiary,  brightness: brightness);

    return base.copyWith(
      secondary: AppColors.secondary,
      onSecondary: sec.onSecondary,
      secondaryContainer: sec.secondaryContainer,
      onSecondaryContainer: sec.onSecondaryContainer,
      tertiary: AppColors.tertiary,
      onTertiary: ter.onTertiary,
      tertiaryContainer: ter.tertiaryContainer,
      onTertiaryContainer: ter.onTertiaryContainer,
    );
  }

  static ThemeData light() {
    final cs = _brandScheme(Brightness.light).copyWith(
      surface: AppColors.lightSurface,
      background: AppColors.lightBackground,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,

      textTheme: Typography.material2021().black.apply(
        bodyColor: cs.onSurface,
        displayColor: cs.onSurface,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cs.surface,
        indicatorColor: cs.primaryContainer,
        labelTextStyle: MaterialStatePropertyAll(
          TextStyle(fontWeight: FontWeight.w600, color: cs.onSurface),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          shape: MaterialStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          padding: const MaterialStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          shape: MaterialStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          side: MaterialStatePropertyAll(
            BorderSide(color: cs.outlineVariant),
          ),
        ),
      ),

      chipTheme: ChipThemeData(
        labelStyle: TextStyle(color: cs.onSurface),
        side: BorderSide(color: cs.outlineVariant),
        shape: const StadiumBorder(),
        selectedColor: cs.primaryContainer,
        disabledColor: cs.surfaceVariant,
        backgroundColor: cs.surface,
      ),

      // ✅ Aqui é CardThemeData (não CardTheme)
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: cs.surface,
      ),
    );
  }

  static ThemeData dark() {
    final cs = _brandScheme(Brightness.dark).copyWith(
      surface: AppColors.darkSurface,
      background: AppColors.darkBackground,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,

      textTheme: Typography.material2021().white.apply(
        bodyColor: cs.onSurface,
        displayColor: cs.onSurface,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cs.surface,
        indicatorColor: cs.primaryContainer,
        labelTextStyle: MaterialStatePropertyAll(
          TextStyle(fontWeight: FontWeight.w600, color: cs.onSurface),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          shape: MaterialStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          padding: const MaterialStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          shape: MaterialStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          side: MaterialStatePropertyAll(
            BorderSide(color: cs.outlineVariant),
          ),
        ),
      ),

      chipTheme: ChipThemeData(
        labelStyle: TextStyle(color: cs.onSurface),
        side: BorderSide(color: cs.outlineVariant),
        shape: const StadiumBorder(),
        selectedColor: cs.primaryContainer,
        disabledColor: cs.surfaceVariant,
        backgroundColor: cs.surface,
      ),

      // ✅ CardThemeData aqui também
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: cs.surface,
      ),
    );
  }
}
