import 'package:flutter/material.dart';

/// Paleta de colores que transmite alegría, confianza, trabajo en equipo y vanguardia
class AppColors {
  AppColors._();

  // Colores primarios - Azul vibrante (confianza y profesionalismo)
  static const Color primary = Color(0xFF1E88E5); // Azul brillante
  static const Color primaryVariant = Color(0xFF1565C0); // Azul más oscuro
  static const Color primaryLight = Color(0xFF64B5F6); // Azul claro
  
  // Colores secundarios - Naranja cálido (alegría y energía)
  static const Color secondary = Color(0xFFFF6F00); // Naranja vibrante
  static const Color secondaryVariant = Color(0xFFE65100); // Naranja oscuro
  static const Color secondaryLight = Color(0xFFFFB74D); // Naranja claro
  
  // Colores de acento - Verde (crecimiento y colaboración)
  static const Color accent = Color(0xFF00C853); // Verde éxito
  static const Color accentLight = Color(0xFF69F0AE); // Verde claro
  
  // Gradientes para efectos vanguardistas
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient heroGradient = LinearGradient(
    colors: [primary, secondary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
  );
  
  // Colores de superficie
  static const Color surface = Color(0xFFFAFAFA);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  static const Color onSurface = Color(0xFF1A1A1A);
  static const Color onSurfaceVariant = Color(0xFF757575);
  
  // Colores de estado
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Sombras y elevaciones
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: primary.withOpacity(0.15),
      offset: const Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];
  
  static List<BoxShadow> mediumShadow = [
    BoxShadow(
      color: primary.withOpacity(0.2),
      offset: const Offset(0, 8),
      blurRadius: 24,
      spreadRadius: 0,
    ),
  ];
  
  static List<BoxShadow> strongShadow = [
    BoxShadow(
      color: onSurface.withOpacity(0.25),
      offset: const Offset(0, 12),
      blurRadius: 36,
      spreadRadius: 0,
    ),
  ];
}