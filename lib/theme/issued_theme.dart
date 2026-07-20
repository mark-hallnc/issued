import 'package:flutter/material.dart';

const issuedPrimary = Color(0xFF1E3A5F);
const issuedPrimaryContainer = Color(0xFFDCE8F7);
const issuedSecondary = Color(0xFF475569);
const issuedSurface = Color(0xFFF8FAFC);
const issuedError = Color(0xFFB42318);

const _disabledBackground = Color(0xFFE2E8F0);
const _disabledForeground = Color(0xFF94A3B8);
const _buttonTextStyle = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w600,
  letterSpacing: 0.1,
);

ThemeData issuedTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: issuedPrimary,
    brightness: Brightness.light,
  ).copyWith(
    primary: issuedPrimary,
    onPrimary: Colors.white,
    primaryContainer: issuedPrimaryContainer,
    secondary: issuedSecondary,
    surface: issuedSurface,
    error: issuedError,
  );
  final roundedShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(14),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: issuedSurface,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF17212F),
      foregroundColor: Colors.white,
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFE7ECF2)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: const TextStyle(color: issuedSecondary),
      helperStyle: const TextStyle(color: Color(0xFF64748B), height: 1.35),
      errorStyle: const TextStyle(color: issuedError, height: 1.25),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD8E0E9)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD8E0E9)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: issuedPrimary, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: issuedError),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: issuedError, width: 1.6),
      ),
    ),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      iconColor: issuedSecondary,
      textColor: Color(0xFF17212F),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFFEEF2F6),
      selectedColor: issuedPrimaryContainer,
      disabledColor: const Color(0xFFF1F5F9),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      labelStyle: const TextStyle(
        color: issuedSecondary,
        fontWeight: FontWeight.w600,
      ),
      secondaryLabelStyle: const TextStyle(
        color: issuedPrimary,
        fontWeight: FontWeight.w700,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFFE7ECF2),
      thickness: 1,
      space: 24,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
        textStyle: const WidgetStatePropertyAll(_buttonTextStyle),
        elevation: const WidgetStatePropertyAll(0),
        shape: WidgetStatePropertyAll(roundedShape),
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.disabled)
              ? _disabledBackground
              : issuedPrimary,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.disabled)
              ? _disabledForeground
              : Colors.white,
        ),
        overlayColor: const WidgetStatePropertyAll(Color(0x1FFFFFFF)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
        textStyle: const WidgetStatePropertyAll(_buttonTextStyle),
        elevation: const WidgetStatePropertyAll(0),
        shape: WidgetStatePropertyAll(roundedShape),
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.disabled)
              ? _disabledBackground
              : issuedPrimary,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.disabled)
              ? _disabledForeground
              : Colors.white,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        ),
        textStyle: const WidgetStatePropertyAll(_buttonTextStyle),
        shape: WidgetStatePropertyAll(roundedShape),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.disabled)
              ? _disabledForeground
              : issuedPrimary,
        ),
        side: WidgetStateProperty.resolveWith(
          (states) => BorderSide(
            color: states.contains(WidgetState.disabled)
                ? const Color(0xFFCBD5E1)
                : const Color(0xFF9EB1C8),
          ),
        ),
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.disabled)
              ? const Color(0xFFF1F5F9)
              : Colors.transparent,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(44, 44)),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        ),
        textStyle: const WidgetStatePropertyAll(_buttonTextStyle),
        shape: WidgetStatePropertyAll(roundedShape),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.disabled)
              ? _disabledForeground
              : issuedPrimary,
        ),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(44, 44)),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.disabled)
              ? _disabledForeground
              : issuedPrimary,
        ),
        shape: WidgetStatePropertyAll(roundedShape),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: issuedPrimary,
      foregroundColor: Colors.white,
      elevation: 1,
      focusElevation: 2,
      hoverElevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      extendedPadding: const EdgeInsets.symmetric(horizontal: 20),
      extendedTextStyle: _buttonTextStyle,
    ),
  );
}

ButtonStyle issuedDestructiveOutlinedButtonStyle(BuildContext context) {
  final error = Theme.of(context).colorScheme.error;
  return OutlinedButton.styleFrom(
    foregroundColor: error,
    side: BorderSide(color: error.withAlpha(150)),
  );
}

ButtonStyle issuedDestructiveFilledButtonStyle(BuildContext context) {
  return FilledButton.styleFrom(
    backgroundColor: Theme.of(context).colorScheme.error,
    foregroundColor: Colors.white,
  );
}
