import 'package:flutter/material.dart';
import '../../core/theme/app_breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Widget responsivo para layouts principales que transmite valores de alegría, confianza y vanguardia
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? laptop;
  final Widget? desktop;
  final EdgeInsets? padding;
  final bool centerContent;
  final Widget? background;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.laptop,
    this.desktop,
    this.padding,
    this.centerContent = false,
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    final width = context.screenWidth;
    final horizontalMargin = context.horizontalMargin;
    
    Widget child;
    
    // Seleccionar layout basado en breakpoint
    if (width >= AppBreakpoints.xl) {
      child = desktop ?? laptop ?? tablet ?? mobile;
    } else if (width >= AppBreakpoints.lg) {
      child = laptop ?? tablet ?? mobile;
    } else if (width >= AppBreakpoints.md) {
      child = tablet ?? mobile;
    } else {
      child = mobile;
    }

    // Aplicar padding responsivo
    child = Padding(
      padding: padding ?? EdgeInsets.symmetric(horizontal: horizontalMargin),
      child: child,
    );

    // Centrar contenido si es necesario
    if (centerContent) {
      child = Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: context.maxContentWidth),
          child: child,
        ),
      );
    }

    // Aplicar background si se proporciona
    if (background != null) {
      child = Stack(
        children: [
          background!,
          child,
        ],
      );
    }

    return child;
  }
}

/// Card responsivo con animaciones suaves para mostrar alegría
class ResponsiveCard extends StatefulWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final bool hover;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final List<BoxShadow>? boxShadow;

  const ResponsiveCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.hover = true,
    this.onTap,
    this.backgroundColor,
    this.boxShadow,
  });

  @override
  State<ResponsiveCard> createState() => _ResponsiveCardState();
}

class _ResponsiveCardState extends State<ResponsiveCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuart,
    ));
    
    _elevationAnimation = Tween<double>(
      begin: 0.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuart,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onEnter(PointerEvent details) {
    if (widget.hover) {
      setState(() => _isHovered = true);
      _controller.forward();
    }
  }

  void _onExit(PointerEvent details) {
    if (widget.hover) {
      setState(() => _isHovered = false);
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = context.screenWidth;
    
    // Padding responsivo
    final responsivePadding = widget.padding ?? EdgeInsets.all(
      screenWidth < AppBreakpoints.sm ? 16.0 : 24.0,
    );
    
    // Margen responsivo
    final responsiveMargin = widget.margin ?? EdgeInsets.all(
      screenWidth < AppBreakpoints.sm ? 8.0 : 16.0,
    );

    return MouseRegion(
      onEnter: _onEnter,
      onExit: _onExit,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: widget.width,
                height: widget.height,
                margin: responsiveMargin,
                decoration: BoxDecoration(
                  color: widget.backgroundColor ?? AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: widget.boxShadow ?? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.1),
                      offset: Offset(0, _elevationAnimation.value),
                      blurRadius: _elevationAnimation.value * 2,
                      spreadRadius: 0,
                    ),
                  ],
                  border: Border.all(
                    color: _isHovered 
                        ? AppColors.primary.withOpacity(0.2)
                        : AppColors.onSurfaceVariant.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: responsivePadding,
                  child: widget.child,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Botón responsivo con gradientes y animaciones para transmitir vanguardia
class ResponsiveButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool isPrimary;
  final double? width;
  final double? height;
  final EdgeInsets? padding;

  const ResponsiveButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isPrimary = true,
    this.width,
    this.height,
    this.padding,
  });

  @override
  State<ResponsiveButton> createState() => _ResponsiveButtonState();
}

class _ResponsiveButtonState extends State<ResponsiveButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 0.1),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = context.screenWidth;
    
    // Padding responsivo
    final responsivePadding = widget.padding ?? EdgeInsets.symmetric(
      horizontal: screenWidth < AppBreakpoints.sm ? 16.0 : 24.0,
      vertical: screenWidth < AppBreakpoints.sm ? 14.0 : 16.0,
    );
    
    // Altura responsiva
    final responsiveHeight = widget.height ?? (
      screenWidth < AppBreakpoints.sm ? 48.0 : 56.0
    );

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                width: widget.width,
                height: responsiveHeight,
                decoration: BoxDecoration(
                  gradient: widget.isPrimary 
                      ? AppColors.primaryGradient
                      : AppColors.secondaryGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: widget.onPressed != null && !widget.isLoading
                      ? AppColors.softShadow
                      : [],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onPressed,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: responsivePadding,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.isLoading) ...[
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            const SizedBox(width: 12),
                          ] else if (widget.icon != null) ...[
                            Icon(
                              widget.icon,
                              color: Colors.white,
                              size: screenWidth < AppBreakpoints.sm ? 18 : 20,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            widget.text,
                            style: AppTypography.labelLarge.copyWith(
                              color: Colors.white,
                              fontSize: screenWidth < AppBreakpoints.sm ? 14 : 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}