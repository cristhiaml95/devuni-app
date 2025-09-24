import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../app/providers/app_providers.dart';
import '../../../domain/entities/rol_usuario.dart';
import '../../../core/types/resultado.dart';

class DialogoInvitarUsuario extends ConsumerStatefulWidget {
  const DialogoInvitarUsuario({super.key});

  @override
  ConsumerState<DialogoInvitarUsuario> createState() =>
      _DialogoInvitarUsuarioState();
}

class _DialogoInvitarUsuarioState extends ConsumerState<DialogoInvitarUsuario> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  RolUsuarioApp _rolSeleccionado = RolUsuarioApp.colaborador;
  bool _cargando = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Invitar Usuario'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email del usuario',
                hintText: 'usuario@ejemplo.com',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingresa un email';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(value)) {
                  return 'Ingresa un email válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<RolUsuarioApp>(
              value: _rolSeleccionado,
              decoration: const InputDecoration(
                labelText: 'Rol del usuario',
                prefixIcon: Icon(Icons.person_outline),
              ),
              items: RolUsuarioApp.values.map((rol) {
                return DropdownMenuItem(
                  value: rol,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(rol.nombre),
                      Text(
                        _getDescripcionRol(rol),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (valor) {
                if (valor != null) {
                  setState(() {
                    _rolSeleccionado = valor;
                  });
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _cargando ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _cargando ? null : _enviarInvitacion,
          child: _cargando
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Enviar Invitación'),
        ),
      ],
    );
  }

  String _getDescripcionRol(RolUsuarioApp rol) {
    switch (rol) {
      case RolUsuarioApp.propietario:
        return 'Control total de la aplicación';
      case RolUsuarioApp.administrador:
        return 'Gestión completa excepto eliminar app';
      case RolUsuarioApp.colaborador:
        return 'Crear y editar inventario';
      case RolUsuarioApp.visor:
        return 'Solo lectura del inventario';
    }
  }

  Future<void> _enviarInvitacion() async {
    if (!_formKey.currentState!.validate()) return;

    final appId = ref.read(appActualIdProvider);
    if (appId == null) return;

    setState(() {
      _cargando = true;
    });

    try {
      final miembrosRepo = ref.read(miembrosRepositoryProvider);
      final resultado = await miembrosRepo.invitarUsuario(
        appId: appId,
        email: _emailController.text.trim(),
        rol: _rolSeleccionado,
      );

      if (mounted) {
        resultado.fold(
          siExito: (invitacion) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Invitación enviada a ${invitacion.email}',
                ),
              ),
            );
          },
          siError: (error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${error.mensajeUsuario}'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error inesperado: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _cargando = false;
        });
      }
    }
  }
}