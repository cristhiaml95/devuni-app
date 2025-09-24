import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/providers/supabase_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/responsive_widgets.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutQuart),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOutQuart),
    ));

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      print('🔐 Iniciando autenticación con Google...');
      final client = ref.read(supabaseClientProvider);

      // Para web, usar localhost:3000 como URL base
      final redirectUrl = 'http://localhost:3000/';

      print('📍 URL de redirect: $redirectUrl');
      print('🌐 Configuración OAuth iniciando...');

      // Para web, usar signInWithOAuth con configuración simplificada
      await client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectUrl,
        authScreenLaunchMode: LaunchMode.platformDefault,
      );

      print('✅ Redirección a Google OAuth iniciada');
    } catch (error) {
      print('❌ Error en autenticación: $error');
      if (!mounted) return;

      // Para testing, mostrar información más detallada
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('⚠️ OAuth no configurado completamente'),
              const SizedBox(height: 4),
              Text('Error: ${error.toString().substring(0, 100)}...'),
              const SizedBox(height: 8),
              const Text(
                '💡 Necesitas configurar Google OAuth en Supabase Dashboard',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveLayout(
        centerContent: true,
        background: _buildBackground(),
        mobile: _buildMobileLayout(context),
        tablet: _buildTabletLayout(context),
        laptop: _buildDesktopLayout(context),
        desktop: _buildDesktopLayout(context),
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF8FAFF), // Azul muy claro
            Color(0xFFFFF8F0), // Naranja muy claro
            Color(0xFFF0FFF4), // Verde muy claro
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Círculos decorativos con opacidad para dar sensación de alegría
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.primary.withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -150,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.secondary.withOpacity(0.1),
                    AppColors.secondary.withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 200,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accent.withOpacity(0.1),
                    AppColors.accent.withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              _buildLogo(isMobile: true),
              const SizedBox(height: 40),
              _buildWelcomeText(isMobile: true),
              const SizedBox(height: 48),
              _buildLoginCard(isMobile: true),
              const SizedBox(height: 40),
              _buildFooterText(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(48.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              _buildLogo(isMobile: false),
              const SizedBox(height: 48),
              _buildWelcomeText(isMobile: false),
              const SizedBox(height: 56),
              Container(
                constraints: const BoxConstraints(maxWidth: 480),
                child: _buildLoginCard(isMobile: false),
              ),
              const SizedBox(height: 48),
              _buildFooterText(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Row(
          children: [
            // Panel izquierdo - Información y branding
            Expanded(
              flex: 5,
              child: Container(
                padding: const EdgeInsets.all(64.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLogo(isMobile: false),
                    const SizedBox(height: 32),
                    Text(
                      'Gestión de inventario\ninteligente y colaborativa',
                      style: AppTypography.displayMedium.copyWith(
                        color: AppColors.onSurface,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Únete a miles de equipos que confían en DevUni para organizar, rastrear y optimizar su inventario de manera eficiente.',
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.onSurfaceVariant,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 40),
                    _buildFeaturesList(),
                  ],
                ),
              ),
            ),
            // Panel derecho - Login
            Expanded(
              flex: 4,
              child: Container(
                height: double.infinity,
                padding: const EdgeInsets.all(64.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildWelcomeText(isMobile: false),
                    const SizedBox(height: 48),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: _buildLoginCard(isMobile: false),
                    ),
                    const SizedBox(height: 32),
                    _buildFooterText(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo({required bool isMobile}) {
    return Row(
      mainAxisAlignment:
          isMobile ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        Container(
          width: isMobile ? 48 : 56,
          height: isMobile ? 48 : 56,
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.inventory_2_rounded,
            color: Colors.white,
            size: 32,
          ),
        ),
        const SizedBox(width: 16),
        Text(
          'DevUni',
          style: (isMobile
                  ? AppTypography.headlineLarge
                  : AppTypography.displaySmall)
              .copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeText({required bool isMobile}) {
    return Column(
      children: [
        Text(
          'Bienvenido de vuelta',
          style: (isMobile
                  ? AppTypography.headlineMedium
                  : AppTypography.headlineLarge)
              .copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Inicia sesión para acceder a tu inventario',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginCard({required bool isMobile}) {
    return ResponsiveCard(
      backgroundColor: Colors.white,
      boxShadow: AppColors.mediumShadow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Iniciar Sesión',
            style: AppTypography.headlineSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ResponsiveButton(
            text: _isLoading ? 'Conectando...' : 'Continuar con Google',
            icon: Icons.login_rounded,
            onPressed: _isLoading ? null : _signInWithGoogle,
            isLoading: _isLoading,
            width: double.infinity,
          ),
          const SizedBox(height: 16),
          Text(
            'Al continuar, aceptas nuestros términos de servicio y política de privacidad.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesList() {
    final features = [
      {'icon': Icons.groups_rounded, 'text': 'Colaboración en equipo'},
      {'icon': Icons.security_rounded, 'text': 'Seguridad avanzada'},
      {'icon': Icons.trending_up_rounded, 'text': 'Analytics en tiempo real'},
      {
        'icon': Icons.mobile_friendly_rounded,
        'text': 'Acceso desde cualquier dispositivo'
      },
    ];

    return Column(
      children: features.map((feature) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  feature['icon'] as IconData,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                feature['text'] as String,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFooterText() {
    return Text(
      '¿Necesitas ayuda? Contacta soporte',
      style: AppTypography.bodySmall.copyWith(
        color: AppColors.onSurfaceVariant,
      ),
      textAlign: TextAlign.center,
    );
  }
}
