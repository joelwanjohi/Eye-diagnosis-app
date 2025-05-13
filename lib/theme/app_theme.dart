import 'package:flutter/material.dart';

class AppTheme {
  // Update these colors to match your AppColors class
  static const Color primaryColor = Color(0xFF16A34A);      // From AppColors.primary[600]
  static const Color secondaryColor = Color(0xFF059669);    // From AppColors.secondary[600]
  static const Color accentColor = Color(0xFF0EA5E9);       // From AppColors.lightBlue[500]
  static const Color backgroundColor = Color(0xFFF9FAFB);   // From AppColors.gray[50]
  static const Color cardColor = Colors.white;              // Keep as is
  static const Color textColor = Color(0xFF1F2937);         // From AppColors.gray[800]
  static const Color textSecondaryColor = Color(0xFF6B7280); // From AppColors.gray[500]
  static const Color errorColor = Color(0xFFE53E3E);        // From AppColors.error[500]
  static const Color successColor = Color(0xFF22C55E);      // From AppColors.success[500]
  static const Color warningColor = Color(0xFFDD6B20);      // From AppColors.warning[500]

  // Update chart colors to match the green-focused scheme
  static const List<Color> chartColors = [
    Color(0xFF16A34A),  // Primary - AppColors.primary[600]
    Color(0xFF059669),  // Secondary - AppColors.secondary[600]
    Color(0xffA7F3D0),  // AppColors.chartColorGreen
    Color(0xffF0FDD4),  // AppColors.chartColorYellow
    Color(0xffD0F5C3),  // AppColors.chartColorBlue
    Color(0xffFDE68A),  // AppColors.chartColorOrange
    Color(0xffC7FCEC),  // AppColors.chartColorPink
    Color(0xffFFD6E0),  // AppColors.chartColorRed
    Color(0xFF0EA5E9),  // AppColors.lightBlue[500]
    Color(0xFF22C55E),  // AppColors.green[500]
  ];

  // Keep the rest of your AppTheme class as is
  static const double borderRadius = 12.0;
  static const double spacing = 16.0;
  static const double buttonRadius = 8.0;

  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      cardTheme: const CardTheme(
        color: cardColor,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
        ),
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        background: backgroundColor,
        surface: cardColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: cardColor,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textColor),
        titleTextStyle: TextStyle(
          color: textColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textColor,
          fontFamily: 'Poppins',
        ),
        displayMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textColor,
          fontFamily: 'Poppins',
        ),
        displaySmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textColor,
          fontFamily: 'Poppins',
        ),
        headlineMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textColor,
          fontFamily: 'Poppins',
        ),
        headlineSmall: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textColor,
          fontFamily: 'Poppins',
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textColor,
          fontFamily: 'Poppins',
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: textColor,
          fontFamily: 'Poppins',
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textColor,
          fontFamily: 'Poppins',
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: textSecondaryColor,
          fontFamily: 'Poppins',
        ),
      ),
      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
        ),
        buttonColor: primaryColor,
        textTheme: ButtonTextTheme.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: primaryColor,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: errorColor, width: 1),
        ),
        hintStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textSecondaryColor,
          fontFamily: 'Poppins',
        ),
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textSecondaryColor,
          fontFamily: 'Poppins',
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE2E8F0),
        thickness: 1,
        space: 1,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return Colors.transparent;
        }),
        side: const BorderSide(width: 1.5, color: Color(0xFFCBD5E0)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFEDF2F7),
        selectedColor: primaryColor.withOpacity(0.1),
        secondarySelectedColor: primaryColor.withOpacity(0.1),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textColor,
          fontFamily: 'Poppins',
        ),
        secondaryLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: primaryColor,
          fontFamily: 'Poppins',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      tabBarTheme: const TabBarTheme(
        labelColor: primaryColor,
        unselectedLabelColor: textSecondaryColor,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          fontFamily: 'Poppins',
        ),
      ),
      dataTableTheme: const DataTableThemeData(
        headingRowColor: MaterialStatePropertyAll(Color(0xFFF7FAFC)),
        dataRowColor: MaterialStatePropertyAll(Colors.white),
        headingTextStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textColor,
          fontFamily: 'Poppins',
        ),
        dataTextStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textColor,
          fontFamily: 'Poppins',
        ),
        horizontalMargin: 16,
        columnSpacing: 24,
        dividerThickness: 1,
      ),
      fontFamily: 'Poppins',
    );
  }

  static ThemeData darkTheme() {
    // Implement dark theme if needed
    return lightTheme();
  }
}