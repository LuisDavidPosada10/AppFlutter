import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData light() {
    const seed = Color(0xFF4F46E5);
    const radius = 16.0;
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.light,
    );

    final baseText = GoogleFonts.montserratTextTheme();

    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFFDFDFD),
      textTheme: baseText,
      visualDensity: VisualDensity.standard,
      brightness: Brightness.light,
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          backgroundColor: scheme.onSurface,
          foregroundColor: scheme.surface,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.onSurface,
        foregroundColor: scheme.surface,
        centerTitle: false,
        scrolledUnderElevation: 0,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        shadowColor: Colors.black12,
        surfaceTintColor: Colors.transparent,
        color: scheme.surface,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      dividerTheme: const DividerThemeData(space: 1),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(scheme.onSurface),
          foregroundColor: WidgetStatePropertyAll(scheme.surface),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) return Colors.white.withValues(alpha: 0.12);
            if (states.contains(WidgetState.hovered)) return Colors.white.withValues(alpha: 0.08);
            if (states.contains(WidgetState.focused)) return Colors.white.withValues(alpha: 0.10);
            return null;
          }),
          padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        labelPadding: const EdgeInsets.symmetric(horizontal: 10),
        backgroundColor: scheme.surfaceContainerHighest,
        side: BorderSide(color: scheme.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
    );
  }
}
