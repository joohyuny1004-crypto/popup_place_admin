import 'package:flutter/material.dart';
import 'admin_colors.dart';

class AdminTheme {
  AdminTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.light(
          primary: AdminColors.primary,
          onPrimary: Colors.white,
          surface: AdminColors.cardBg,
          onSurface: AdminColors.textPrimary,
          error: AdminColors.error,
        ),
        scaffoldBackgroundColor: AdminColors.contentBg,
        cardTheme: CardThemeData(
          elevation: 0,
          color: AdminColors.cardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AdminColors.cardBorder),
          ),
          margin: EdgeInsets.zero,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AdminColors.textPrimary,
          ),
          headlineMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AdminColors.textPrimary,
          ),
          bodyLarge: TextStyle(
            fontSize: 14,
            color: AdminColors.textPrimary,
          ),
          bodyMedium: TextStyle(
            fontSize: 13,
            color: AdminColors.textSecondary,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            color: AdminColors.textSecondary,
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: AdminColors.cardBorder,
          thickness: 1,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AdminColors.cardBg,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AdminColors.cardBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AdminColors.cardBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AdminColors.primary, width: 2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AdminColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AdminColors.primaryLight,
          selectedColor: AdminColors.primary,
          labelStyle: const TextStyle(
            fontSize: 12,
            color: AdminColors.primary,
          ),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          side: BorderSide.none,
        ),
      );
}
