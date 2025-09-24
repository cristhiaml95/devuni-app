import 'package:flutter/material.dart';

class ResponsiveHelper {
  static const double tabletBreak = 768.0;
  static const double desktopBreak = 1024.0;
  
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < tabletBreak;
  }
  
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= tabletBreak && width < desktopBreak;
  }
  
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreak;
  }
  
  static double getMaxWidth(BuildContext context) {
    if (isDesktop(context)) return 1200.0;
    if (isTablet(context)) return 800.0;
    return double.infinity;
  }
  
  static EdgeInsets getPadding(BuildContext context) {
    if (isDesktop(context)) return const EdgeInsets.all(24.0);
    if (isTablet(context)) return const EdgeInsets.all(20.0);
    return const EdgeInsets.all(16.0);
  }
  
  static int getCrossAxisCount(BuildContext context, {
    int mobile = 1,
    int tablet = 2,
    int desktop = 3,
  }) {
    if (isDesktop(context)) return desktop;
    if (isTablet(context)) return tablet;
    return mobile;
  }
}

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, BoxConstraints constraints) builder;
  
  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: builder);
  }
}

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  
  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
  });
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? ResponsiveHelper.getMaxWidth(context),
        ),
        padding: ResponsiveHelper.getPadding(context),
        child: child,
      ),
    );
  }
}