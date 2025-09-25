import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/supabase_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/responsive_widgets.dart';
import '../apps/providers/apps_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final selectedApp = ref.watch(selectedAppProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          selectedApp?.name ?? 'Dashboard',
          style: AppTypography.headlineSmall,
        ),
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Cambiar de App
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            onPressed: () => context.go('/apps'),
            tooltip: 'Cambiar App',
          ),
          // Logout
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              print('🔐 Cerrando sesión...');
              final supabase = ref.read(supabaseClientProvider);
              await supabase.auth.signOut();
            },
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(context, ref, user, selectedApp),
        tablet: _buildTabletLayout(context, ref, user, selectedApp),
        desktop: _buildDesktopLayout(context, ref, user, selectedApp),
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    WidgetRef ref,
    dynamic user,
    dynamic selectedApp,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(context, user, selectedApp),
          const SizedBox(height: 20),
          _buildModulesGrid(context, 1),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(
    BuildContext context,
    WidgetRef ref,
    dynamic user,
    dynamic selectedApp,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(context, user, selectedApp),
          const SizedBox(height: 24),
          _buildModulesGrid(context, 2),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    WidgetRef ref,
    dynamic user,
    dynamic selectedApp,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(context, user, selectedApp),
          const SizedBox(height: 32),
          _buildModulesGrid(context, 3),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(
      BuildContext context, dynamic user, dynamic selectedApp) {
    return ResponsiveCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.business,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¡Bienvenido a ${selectedApp?.name ?? "tu App"}!',
                        style: AppTypography.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      if (user?.email != null)
                        Text(
                          user.email,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (selectedApp?.description?.isNotEmpty == true) ...[
              const SizedBox(height: 16),
              Text(
                selectedApp!.description!,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildModulesGrid(BuildContext context, int crossAxisCount) {
    final modules = [
      _ModuleData(
        title: 'Inventario',
        description: 'Gestiona productos, stock y movimientos',
        icon: Icons.inventory_2,
        color: Colors.blue,
        route: '/dashboard/inventario',
      ),
      _ModuleData(
        title: 'Reportes',
        description: 'Análisis y estadísticas de tu negocio',
        icon: Icons.analytics,
        color: Colors.green,
        route: null, // Pendiente de implementar
      ),
      _ModuleData(
        title: 'Configuración',
        description: 'Catálogos, usuarios y permisos',
        icon: Icons.settings,
        color: Colors.orange,
        route: null, // Pendiente de implementar
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 1.1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: modules.length,
      itemBuilder: (context, index) {
        final module = modules[index];
        return _buildModuleCard(context, module);
      },
    );
  }

  Widget _buildModuleCard(BuildContext context, _ModuleData module) {
    final isAvailable = module.route != null;

    return ResponsiveCard(
      onTap: isAvailable ? () => context.go(module.route!) : null,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: isAvailable
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    module.color.withOpacity(0.1),
                    module.color.withOpacity(0.05),
                  ],
                )
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isAvailable
                    ? module.color.withOpacity(0.2)
                    : AppColors.onSurfaceVariant.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                module.icon,
                size: 32,
                color: isAvailable
                    ? module.color
                    : AppColors.onSurfaceVariant.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              module.title,
              style: AppTypography.titleMedium.copyWith(
                color: isAvailable
                    ? AppColors.onSurface
                    : AppColors.onSurfaceVariant.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              module.description,
              style: AppTypography.bodySmall.copyWith(
                color: isAvailable
                    ? AppColors.onSurfaceVariant
                    : AppColors.onSurfaceVariant.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (!isAvailable) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.onSurfaceVariant.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Próximamente',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ModuleData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String? route;

  _ModuleData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.route,
  });
}
