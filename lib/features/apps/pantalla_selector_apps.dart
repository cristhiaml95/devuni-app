import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../app/providers/app_providers.dart';
import '../../domain/entities/app_entidad.dart';
import '../../core/types/resultado.dart';
import 'widgets/dialogo_crear_app.dart';
import 'widgets/tarjeta_app.dart';
import 'widgets/seccion_invitaciones.dart';

class PantallaSelectorApps extends ConsumerStatefulWidget {
  const PantallaSelectorApps({super.key});

  @override
  ConsumerState<PantallaSelectorApps> createState() => _PantallaSelectorAppsState();
}

class _PantallaSelectorAppsState extends ConsumerState<PantallaSelectorApps>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final usuario = ref.watch(usuarioActualProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Aplicaciones'),
        actions: [
          // Avatar del usuario
          if (usuario?.userMetadata?['avatar_url'] != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                  usuario!.userMetadata!['avatar_url'] as String,
                ),
                radius: 16,
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: CircleAvatar(
                backgroundColor: theme.colorScheme.primary,
                radius: 16,
                child: Text(
                  (usuario?.email?.substring(0, 1).toUpperCase() ?? 'U'),
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          // Botón de logout
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _cerrarSesion();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Cerrar Sesión'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Mis Apps', icon: Icon(Icons.folder)),
            Tab(text: 'Compartidas', icon: Icon(Icons.group)),
            Tab(text: 'Accesibles', icon: Icon(Icons.apps)),
            Tab(text: 'Invitaciones', icon: Icon(Icons.mail)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _TabMisApps(),
          _TabAppsCompartidas(),
          _TabAppsAccesibles(),
          _TabInvitaciones(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarDialogoCrearApp(context),
        icon: const Icon(Icons.add),
        label: const Text('Nueva App'),
      ),
    );
  }

  void _mostrarDialogoCrearApp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const DialogoCrearApp(),
    );
  }

  Future<void> _cerrarSesion() async {
    try {
      final client = ref.read(supabaseClientProvider);
      await client.auth.signOut();
      
      // Limpiar app actual
      ref.read(appActualIdProvider.notifier).state = null;
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cerrar sesión: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}

class _TabMisApps extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<Resultado<List<AppEntidad>>>(
      future: ref.watch(appsRepositoryProvider).obtenerMisApps(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text('Error al cargar apps'),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        final resultado = snapshot.data;
        if (resultado == null) {
          return const Center(child: Text('No hay datos'));
        }

        return resultado.fold(
          siExito: (apps) {
            if (apps.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.folder_outlined, size: 64),
                    SizedBox(height: 16),
                    Text('No tienes aplicaciones'),
                    SizedBox(height: 8),
                    Text('Crea tu primera aplicación para empezar'),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: apps.length,
              itemBuilder: (context, index) {
                return TarjetaApp(
                  app: apps[index],
                  esPropietario: true,
                  onTap: () => _seleccionarApp(ref, apps[index].id),
                );
              },
            );
          },
          siError: (error) => Center(
            child: Text('Error: ${error.mensajeUsuario}'),
          ),
        );
      },
    );
  }

  void _seleccionarApp(WidgetRef ref, String appId) {
    ref.read(appActualIdProvider.notifier).state = appId;
  }
}

class _TabAppsCompartidas extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<Resultado<List<AppEntidad>>>(
      future: ref.watch(appsRepositoryProvider).obtenerAppsCompartidasConmigo(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final resultado = snapshot.data;
        if (resultado == null) {
          return const Center(child: Text('No hay datos'));
        }

        return resultado.fold(
          siExito: (apps) {
            if (apps.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.group_outlined, size: 64),
                    SizedBox(height: 16),
                    Text('No tienes apps compartidas'),
                    SizedBox(height: 8),
                    Text('Las apps compartidas contigo aparecerán aquí'),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: apps.length,
              itemBuilder: (context, index) {
                return TarjetaApp(
                  app: apps[index],
                  esPropietario: false,
                  onTap: () => _seleccionarApp(ref, apps[index].id),
                );
              },
            );
          },
          siError: (error) => Center(
            child: Text('Error: ${error.mensajeUsuario}'),
          ),
        );
      },
    );
  }

  void _seleccionarApp(WidgetRef ref, String appId) {
    ref.read(appActualIdProvider.notifier).state = appId;
  }
}

class _TabAppsAccesibles extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<Resultado<List<AppEntidad>>>(
      future: ref.watch(appsRepositoryProvider).obtenerAppsAccesibles(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final resultado = snapshot.data;
        if (resultado == null) {
          return const Center(child: Text('No hay datos'));
        }

        return resultado.fold(
          siExito: (apps) {
            if (apps.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.apps_outlined, size: 64),
                    SizedBox(height: 16),
                    Text('No tienes acceso a aplicaciones'),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: apps.length,
              itemBuilder: (context, index) {
                final usuario = ref.watch(usuarioActualProvider);
                final esPropietario = apps[index].propietarioId == usuario?.id;
                
                return TarjetaApp(
                  app: apps[index],
                  esPropietario: esPropietario,
                  onTap: () => _seleccionarApp(ref, apps[index].id),
                );
              },
            );
          },
          siError: (error) => Center(
            child: Text('Error: ${error.mensajeUsuario}'),
          ),
        );
      },
    );
  }

  void _seleccionarApp(WidgetRef ref, String appId) {
    ref.read(appActualIdProvider.notifier).state = appId;
  }
}

class _TabInvitaciones extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const SeccionInvitaciones();
  }
}