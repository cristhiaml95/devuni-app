import 'package:flutter/material.dart';

/// Breakpoints responsivos para diferentes tamaños de pantalla
class AppBreakpoints {
  AppBreakpoints._();
  
  // Breakpoints siguiendo Material Design guidelines
  static const double xs = 0;      // Teléfonos pequeños
  static const double sm = 600;    // Teléfonos grandes / tablets pequeñas en portrait
  static const double md = 840;    // Tablets en portrait / móviles en landscape
  static const double lg = 1200;   // Tablets en landscape / laptops pequeñas
  static const double xl = 1600;   // Desktops / laptops grandes
  static const double xxl = 1920;  // Pantallas muy grandes

  /// Obtiene el tipo de dispositivo basado en el ancho de pantalla
  static DeviceType getDeviceType(double width) {
    if (width < sm) return DeviceType.mobile;
    if (width < md) return DeviceType.tablet;
    if (width < lg) return DeviceType.laptop;
    return DeviceType.desktop;
  }
  
  /// Obtiene márgenes responsivos basados en el ancho de pantalla
  static double getHorizontalMargin(double width) {
    if (width < sm) return 16.0;      // Mobile: 16px
    if (width < md) return 24.0;      // Tablet small: 24px
    if (width < lg) return 32.0;      // Tablet large: 32px
    if (width < xl) return 48.0;      // Laptop: 48px
    return 64.0;                      // Desktop: 64px
  }
  
  /// Obtiene el ancho máximo del contenido basado en el tipo de pantalla
  static double getMaxContentWidth(double screenWidth) {
    if (screenWidth < sm) return screenWidth - 32;  // Mobile: margen total 32px
    if (screenWidth < md) return screenWidth - 48;  // Tablet: margen total 48px
    if (screenWidth < lg) return 800;               // Max 800px en laptops
    return 1200;                                    // Max 1200px en desktop
  }
  
  /// Obtiene el número de columnas para grids responsivos
  static int getGridColumns(double width) {
    if (width < sm) return 1;      // Mobile: 1 columna
    if (width < md) return 2;      // Tablet small: 2 columnas
    if (width < lg) return 3;      // Tablet large: 3 columnas
    if (width < xl) return 4;      // Laptop: 4 columnas
    return 6;                      // Desktop: 6 columnas
  }
  
  /// Obtiene el aspect ratio para cards responsivos
  static double getCardAspectRatio(double width) {
    if (width < sm) return 1.5;    // Mobile: más alto
    if (width < md) return 1.3;    // Tablet: intermedio
    return 1.2;                    // Desktop: más ancho
  }
}

enum DeviceType {
  mobile,
  tablet, 
  laptop,
  desktop,
}

/// Extension para obtener información del dispositivo desde MediaQuery
extension ResponsiveExtension on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  
  DeviceType get deviceType => AppBreakpoints.getDeviceType(screenWidth);
  
  bool get isMobile => deviceType == DeviceType.mobile;
  bool get isTablet => deviceType == DeviceType.tablet;
  bool get isLaptop => deviceType == DeviceType.laptop;
  bool get isDesktop => deviceType == DeviceType.desktop;
  
  double get horizontalMargin => AppBreakpoints.getHorizontalMargin(screenWidth);
  double get maxContentWidth => AppBreakpoints.getMaxContentWidth(screenWidth);
  int get gridColumns => AppBreakpoints.getGridColumns(screenWidth);
  double get cardAspectRatio => AppBreakpoints.getCardAspectRatio(screenWidth);
}