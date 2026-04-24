import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - من لوحة الهوية البصرية
  static const Color primaryDark = Color(0xFF0F3D2E);    // أخضر أساسي داكن
  static const Color primaryMedium = Color(0xFF166A4A);   // أخضر ثانوي
  static const Color primaryLight = Color(0xFF22C55E);    // أخضر نجاح
  static const Color primaryGradientEnd = Color(0xFF06261D); // تدرج أخضر داكن

  // Secondary Colors
  static const Color darkGray = Color(0xFF22272A);        // رمادي داكن
  static const Color mediumGray = Color(0xFF6B7280);      // رمادي متوسط
  static const Color lightGray = Color(0xFFE5E7EB);       // رمادي فاتح
  static const Color background = Color(0xFFF3F4F6);      // خلفية
  static const Color white = Color(0xFFFFFFFF);           // أبيض

  // Semantic Colors
  static const Color error = Color(0xFFEF4444);           // خطأ - أحمر
  static const Color success = Color(0xFF22C55E);         // نجاح - أخضر
  static const Color warning = Color(0xFFD4AF37);         // تحذير - ذهبي
  static const Color errorDark = Color(0xFF8B1D24);       // أحمر داكن
  static const Color errorLight = Color(0xFFFCE7E9);      // وردي فاتح

  // Card & Surface
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF8FAF9);

  // Text Colors
  static const Color textPrimary = Color(0xFF0F3D2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textOnDark = Color(0xFFFFFFFF);
  static const Color textSubtitle = Color(0xFF9CA3AF);

  // Drawer Colors
  static const Color drawerBackground = Color(0xFF0F3D2E);
  static const Color drawerActiveItem = Color(0xFF166A4A);
  static const Color drawerItemText = Color(0xFFFFFFFF);
  static const Color drawerDivider = Color(0xFF1A5C40);

  // BottomNav Colors
  static const Color bottomNavBackground = Color(0xFF0F3D2E);
  static const Color bottomNavActive = Color(0xFF22C55E);
  static const Color bottomNavInactive = Color(0xFF9DBFB4);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDark, primaryGradientEnd],
  );

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryMedium, primaryDark],
  );
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryDark,
        secondary: AppColors.primaryMedium,
        surface: AppColors.cardBackground,
        error: AppColors.error,
      ),
      fontFamily: 'myfont',
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.white,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: 'myfont',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
        ),
        iconTheme: IconThemeData(color: AppColors.white),
      ),
      cardTheme: CardTheme(
        color: AppColors.cardBackground,
        elevation: 2,
        shadowColor: Color(0x1A0F3D2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'myfont',
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          elevation: 2,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryMedium,
          textStyle: const TextStyle(
            fontFamily: 'myfont',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryMedium, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        labelStyle: const TextStyle(color: AppColors.mediumGray),
        hintStyle: const TextStyle(color: AppColors.textSubtitle),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightGray,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.primaryDark,
        contentTextStyle: const TextStyle(
          fontFamily: 'myfont',
          color: AppColors.white,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        behavior: SnackBarBehavior.floating,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.primaryDark,
        selectedItemColor: AppColors.primaryLight,
        unselectedItemColor: AppColors.bottomNavInactive,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

// Text Styles
class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontFamily: 'myfont',
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading2 = TextStyle(
    fontFamily: 'myfont',
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading3 = TextStyle(
    fontFamily: 'myfont',
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontFamily: 'myfont',
    fontSize: 14,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySecondary = TextStyle(
    fontFamily: 'myfont',
    fontSize: 13,
    color: AppColors.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: 'myfont',
    fontSize: 11,
    color: AppColors.textSubtitle,
  );

  static const TextStyle amountLarge = TextStyle(
    fontFamily: 'myfont',
    fontSize: 22,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle amountMedium = TextStyle(
    fontFamily: 'myfont',
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle onDark = TextStyle(
    fontFamily: 'myfont',
    fontSize: 14,
    color: AppColors.textOnDark,
  );

  static const TextStyle onDarkBold = TextStyle(
    fontFamily: 'myfont',
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.textOnDark,
  );
}

// Shadows
class AppShadows {
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: AppColors.primaryDark.withOpacity(0.08),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get headerShadow => [
    BoxShadow(
      color: AppColors.primaryDark.withOpacity(0.2),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> get buttonShadow => [
    BoxShadow(
      color: AppColors.primaryLight.withOpacity(0.3),
      blurRadius: 8,
      offset: const Offset(0, 3),
    ),
  ];
}
