import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Tipografía moderna y legible que transmite profesionalismo y vanguardia
class AppTypography {
  AppTypography._();

  // Familia de fuentes moderna (Inter es excelente para UI)
  static const String fontFamily = 'Inter';
  
  // Escalas de tamaño responsivas
  static const double baseSize = 16.0;
  
  // Display - Para títulos principales y hero sections
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 48,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    height: 1.1,
    color: AppColors.onSurface,
  );
  
  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.25,
    height: 1.2,
    color: AppColors.onSurface,
  );
  
  static const TextStyle displaySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.3,
    color: AppColors.onSurface,
  );
  
  // Headlines - Para títulos de secciones
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.3,
    color: AppColors.onSurface,
  );
  
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.4,
    color: AppColors.onSurface,
  );
  
  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    height: 1.4,
    color: AppColors.onSurface,
  );
  
  // Titles - Para subtítulos y navegación
  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    height: 1.5,
    color: AppColors.onSurface,
  );
  
  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.5,
    color: AppColors.onSurface,
  );
  
  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.5,
    color: AppColors.onSurfaceVariant,
  );
  
  // Body - Para texto principal
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: baseSize,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
    height: 1.6,
    color: AppColors.onSurface,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.6,
    color: AppColors.onSurface,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.6,
    color: AppColors.onSurfaceVariant,
  );
  
  // Labels - Para botones y elementos de UI
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.4,
    color: AppColors.onSurface,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.4,
    color: AppColors.onSurface,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.4,
    color: AppColors.onSurfaceVariant,
  );
  
  // Estilos especiales para diferentes estados emocionales
  static const TextStyle confident = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.4,
    color: AppColors.primary,
  );
  
  static const TextStyle cheerful = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.5,
    color: AppColors.secondary,
  );
  
  static const TextStyle teamwork = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.25,
    height: 1.5,
    color: AppColors.accent,
  );
  
  // Método para obtener estilos responsivos
  static TextStyle getResponsiveTitle(double screenWidth) {
    if (screenWidth < 600) return headlineSmall;
    if (screenWidth < 840) return headlineMedium;
    return headlineLarge;
  }
  
  static TextStyle getResponsiveDisplay(double screenWidth) {
    if (screenWidth < 600) return displaySmall;
    if (screenWidth < 1200) return displayMedium;
    return displayLarge;
  }
}