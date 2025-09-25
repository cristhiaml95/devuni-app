import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

import '../../../core/widgets/responsive_widgets.dart';
import '../providers/apps_provider.dart';
import '../models/app_model.dart';

/// Pantalla selector de Apps (espacios de trabajo) para multi-tenancy
class AppsSelectorScreen extends ConsumerWidget {
  const AppsSelectorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAppsAsync = ref.watch(userAppsProvider);
    final memberAppsAsync = ref.watch(memberAppsProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: ResponsiveLayout(
        mobile:
            _buildMobileLayout(context, ref, userAppsAsync, memberAppsAsync),
        tablet:
            _buildTabletLayout(context, ref, userAppsAsync, memberAppsAsync),
        desktop:
            _buildDesktopLayout(context, ref, userAppsAsync, memberAppsAsync),
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<AppModel>> userAppsAsync,
    AsyncValue<List<AppModel>> memberAppsAsync,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          _buildHeader(context),
          const SizedBox(height: 32),
          _buildAppsSection(context, ref, userAppsAsync, memberAppsAsync),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<AppModel>> userAppsAsync,
    AsyncValue<List<AppModel>> memberAppsAsync,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60),
          _buildHeader(context),
          const SizedBox(height: 40),
          _buildAppsSection(context, ref, userAppsAsync, memberAppsAsync),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<AppModel>> userAppsAsync,
    AsyncValue<List<AppModel>> memberAppsAsync,
  ) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              _buildHeader(context),
              const SizedBox(height: 48),
              _buildAppsSection(context, ref, userAppsAsync, memberAppsAsync),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tus Espacios de Trabajo',
          style: AppTypography.headlineLarge.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Selecciona un espacio de trabajo para continuar',
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildAppsSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<AppModel>> userAppsAsync,
    AsyncValue<List<AppModel>> memberAppsAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mis Apps (owner)
        _buildSectionTitle('Mis Apps'),
        const SizedBox(height: 16),
        _buildAppsGrid(context, ref, userAppsAsync, true),

        const SizedBox(height: 32),

        // Apps donde soy miembro
        _buildSectionTitle('Apps Compartidas'),
        const SizedBox(height: 16),
        _buildAppsGrid(context, ref, memberAppsAsync, false),

        const SizedBox(height: 32),

        // Botón crear nueva App
        _buildCreateAppButton(context, ref),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTypography.headlineSmall.copyWith(
        color: AppColors.onSurface,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildAppsGrid(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<AppModel>> appsAsync,
    bool isOwner,
  ) {
    return appsAsync.when(
      data: (apps) {
        if (apps.isEmpty) {
          return _buildEmptyState(isOwner);
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);
            
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 1.1, // Hacer cards un poco más altas
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: apps.length,
              itemBuilder: (context, index) {
                return _buildAppCard(context, ref, apps[index], isOwner);
              },
            );
          },
        );
      },
      loading: () => _buildLoadingGrid(),
      error: (error, stack) => _buildErrorState(error.toString()),
    );
  }  int _getCrossAxisCount(double width) {
    if (width < 600) return 1; // Mobile: 1 columna
    if (width < 900) return 2; // Tablet: 2 columnas
    return 3; // Desktop: 3 columnas
  }

  Widget _buildAppCard(
    BuildContext context,
    WidgetRef ref,
    AppModel app,
    bool isOwner,
  ) {
    return ResponsiveCard(
      onTap: () => _selectApp(context, ref, app),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icono y badge owner
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.business,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const Spacer(),
                if (isOwner)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'OWNER',
                      style: AppTypography.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Nombre del App
            Text(
              app.name,
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 4),

            // Descripción
            if (app.description.isNotEmpty)
              Flexible(
                child: Text(
                  app.description,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isOwner) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            isOwner ? Icons.add_business : Icons.share,
            size: 64,
            color: AppColors.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            isOwner ? 'No tienes Apps creadas' : 'No tienes Apps compartidas',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isOwner
                ? 'Crea tu primera App para comenzar'
                : 'Espera a que te inviten a un espacio',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 1.1,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: 4,
          itemBuilder: (context, index) {
            return ResponsiveCard(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.onSurfaceVariant.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppColors.onSurfaceVariant.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 100,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppColors.onSurfaceVariant.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error al cargar Apps',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCreateAppButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showCreateAppDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Crear Nueva App'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _selectApp(BuildContext context, WidgetRef ref, AppModel app) {
    print('📱 APPS: Seleccionando App: ${app.name} (${app.id})');

    // Actualizar el App seleccionada
    ref.read(selectedAppProvider.notifier).state = app;

    // Navegar al dashboard principal
    context.go('/dashboard');
  }

  void _showCreateAppDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _CreateAppDialog(ref: ref);
      },
    );
  }
}

/// Dialog para crear nueva App
class _CreateAppDialog extends ConsumerStatefulWidget {
  final WidgetRef ref;

  const _CreateAppDialog({required this.ref});

  @override
  ConsumerState<_CreateAppDialog> createState() => _CreateAppDialogState();
}

class _CreateAppDialogState extends ConsumerState<_CreateAppDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Crear Nueva App',
        style: AppTypography.headlineSmall.copyWith(
          color: AppColors.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre de la App',
                hintText: 'Ej: Mi Inventario',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El nombre es requerido';
                }
                if (value.trim().length < 3) {
                  return 'Mínimo 3 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
                hintText: 'Describe tu espacio de trabajo',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _createApp,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Crear'),
        ),
      ],
    );
  }

  Future<void> _createApp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final appsRepository = widget.ref.read(appsRepositoryProvider);

      final newApp = await appsRepository.createApp(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );

      print('📱 APPS: App creada exitosamente: ${newApp.name}');

      if (mounted) {
        Navigator.of(context).pop();

        // Opcional: Seleccionar automáticamente la nueva App
        widget.ref.read(selectedAppProvider.notifier).state = newApp;

        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('App "${newApp.name}" creada exitosamente'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (error) {
      print('❌ Error al crear App: $error');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear App: $error'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
