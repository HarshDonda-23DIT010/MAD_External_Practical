import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary Colors
  static const Color primaryColor = Color(0xFF4F46E5);
  static const Color primaryDark = Color(0xFF3730A3);
  static const Color primaryLight = Color(0xFF818CF8);

  // Accent Colors
  static const Color accentColor = Color(0xFF0EA5E9);
  static const Color accentDark = Color(0xFF0369A1);

  // Background Colors
  static const Color scaffoldBg = Color(0xFFF3F4F6);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color surfaceBg = Color(0xFFF9FAFB);
  static const Color surfaceLight = Color(0xFFE5E7EB);

  // Text Colors
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF4B5563);
  static const Color textHint = Color(0xFF9CA3AF);

  // Status Colors
  static const Color success = Color(0xFF00E676);
  static const Color warning = Color(0xFFFFD740);
  static const Color error = Color(0xFFFF5252);
  static const Color info = Color(0xFF448AFF);

  // File Type Colors
  static const Color pdfColor = Color(0xFFE53935);
  static const Color docColor = Color(0xFF1565C0);
  static const Color pptColor = Color(0xFFFF6F00);
  static const Color xlsColor = Color(0xFF2E7D32);
  static const Color imgColor = Color(0xFF7B1FA2);
  static const Color txtColor = Color(0xFF78909C);
  static const Color zipColor = Color(0xFF5D4037);
  static const Color defaultFileColor = Color(0xFF546E7A);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, accentColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF9FAFB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sharedGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF00D2FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: scaffoldBg,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: accentColor,
        surface: cardBg,
        error: error,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.light().textTheme,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBg,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceBg,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: error, width: 1),
        ),
        hintStyle: GoogleFonts.inter(color: textHint, fontSize: 14),
        labelStyle: GoogleFonts.inter(color: textSecondary, fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 8,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceBg,
        selectedColor: primaryColor.withValues(alpha: 0.3),
        labelStyle: GoogleFonts.inter(fontSize: 12, color: textPrimary),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: cardBg,
        selectedItemColor: primaryColor,
        unselectedItemColor: textHint,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 11),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceLight,
        contentTextStyle: GoogleFonts.inter(color: textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Get file type color
  static Color getFileTypeColor(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return pdfColor;
      case 'doc':
      case 'docx':
        return docColor;
      case 'ppt':
      case 'pptx':
        return pptColor;
      case 'xls':
      case 'xlsx':
        return xlsColor;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return imgColor;
      case 'txt':
        return txtColor;
      case 'zip':
      case 'rar':
        return zipColor;
      default:
        return defaultFileColor;
    }
  }

  /// Get file type icon
  static IconData getFileTypeIcon(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'doc':
      case 'docx':
        return Icons.description_rounded;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow_rounded;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart_rounded;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image_rounded;
      case 'txt':
        return Icons.text_snippet_rounded;
      case 'zip':
      case 'rar':
        return Icons.folder_zip_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  /// Format file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
