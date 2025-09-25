import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/responsive_widgets.dart';
import '../../apps/providers/apps_provider.dart';
import '../../../data/providers.dart';
import '../../../domain/models.dart';

class ProductoFormScreen extends ConsumerStatefulWidget {
  final String? productoId;

  const ProductoFormScreen({
    super.key,
    this.productoId,
  });

  @override
  ConsumerState<ProductoFormScreen> createState() => _ProductoFormScreenState();
}

class _ProductoFormScreenState extends ConsumerState<ProductoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _precioController = TextEditingController();
  final _stockMinimoController = TextEditingController();
  final _stockMaximoController = TextEditingController();
  final _codigoBarrasController = TextEditingController();
  final _skuController = TextEditingController();

  String? _selectedCategoriaId;
  String? _selectedUnidadMedidaId;
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.productoId != null;
    if (_isEditing) {
      _loadProducto();
    }
  }

  void _loadProducto() {
    // TODO: Cargar producto existente si estamos editando
    // final producto = ref.read(productoByIdProvider(widget.productoId!));
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _precioController.dispose();
    _stockMinimoController.dispose();
    _stockMaximoController.dispose();
    _codigoBarrasController.dispose();
    _skuController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedApp = ref.watch(selectedAppProvider);

    if (selectedApp == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Editar Producto' : 'Nuevo Producto'),
        ),
        body: const Center(
          child: Text('No hay app seleccionada'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Editar Producto' : 'Nuevo Producto',
          style: AppTypography.headlineSmall,
        ),
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _submitForm,
              child: Text(
                _isEditing ? 'Actualizar' : 'Crear',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(context),
        tablet: _buildTabletLayout(context),
        desktop: _buildDesktopLayout(context),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _buildForm(context),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: _buildForm(context),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: _buildForm(context),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Información básica
          ResponsiveCard(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Información Básica',
                    style: AppTypography.titleMedium,
                  ),
                  const SizedBox(height: 16),

                  // Nombre del producto
                  TextFormField(
                    controller: _nombreController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del producto *',
                      hintText: 'Ej: Camiseta básica blanca',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El nombre es obligatorio';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Descripción
                  TextFormField(
                    controller: _descripcionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      hintText: 'Descripción detallada del producto',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  // SKU y Código de barras
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _skuController,
                          decoration: const InputDecoration(
                            labelText: 'SKU',
                            hintText: 'Código único',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _codigoBarrasController,
                          decoration: const InputDecoration(
                            labelText: 'Código de barras',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Categorización
          ResponsiveCard(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Categorización',
                    style: AppTypography.titleMedium,
                  ),
                  const SizedBox(height: 16),

                  // Categoría
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedCategoriaId,
                          decoration: const InputDecoration(
                            labelText: 'Categoría',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: null,
                              child: Text('Seleccionar categoría'),
                            ),
                            // TODO: Cargar categorías reales
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedCategoriaId = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _showCreateCategoriaDialog(),
                        icon: const Icon(Icons.add_circle_outline),
                        tooltip: 'Crear nueva categoría',
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          foregroundColor: AppColors.primary,
                        ),
                      ),
                      IconButton(
                        onPressed: _selectedCategoriaId != null
                            ? () => _showEditCategoriaDialog()
                            : null,
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: 'Editar categoría',
                        style: IconButton.styleFrom(
                          backgroundColor: _selectedCategoriaId != null
                              ? AppColors.secondary.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.1),
                          foregroundColor: _selectedCategoriaId != null
                              ? AppColors.secondary
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Unidad de medida
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedUnidadMedidaId,
                          decoration: const InputDecoration(
                            labelText: 'Unidad de medida',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: null,
                              child: Text('Seleccionar unidad'),
                            ),
                            // TODO: Cargar unidades reales
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedUnidadMedidaId = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _showCreateUnidadDialog(),
                        icon: const Icon(Icons.add_circle_outline),
                        tooltip: 'Crear nueva unidad de medida',
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          foregroundColor: AppColors.primary,
                        ),
                      ),
                      IconButton(
                        onPressed: _selectedUnidadMedidaId != null
                            ? () => _showEditUnidadDialog()
                            : null,
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: 'Editar unidad de medida',
                        style: IconButton.styleFrom(
                          backgroundColor: _selectedUnidadMedidaId != null
                              ? AppColors.secondary.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.1),
                          foregroundColor: _selectedUnidadMedidaId != null
                              ? AppColors.secondary
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Inventario
          ResponsiveCard(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Control de Inventario',
                    style: AppTypography.titleMedium,
                  ),
                  const SizedBox(height: 16),

                  // Precio
                  TextFormField(
                    controller: _precioController,
                    decoration: const InputDecoration(
                      labelText: 'Precio unitario',
                      prefixText: '\$ ',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final precio = double.tryParse(value);
                        if (precio == null || precio < 0) {
                          return 'Ingresa un precio válido';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Stock mínimo y máximo
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _stockMinimoController,
                          decoration: const InputDecoration(
                            labelText: 'Stock mínimo',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _stockMaximoController,
                          decoration: const InputDecoration(
                            labelText: 'Stock máximo',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Botones de acción
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isLoading ? null : () => context.pop(),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_isEditing ? 'Actualizar' : 'Crear Producto'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final selectedApp = ref.read(selectedAppProvider);
      if (selectedApp == null) {
        throw Exception('No hay app seleccionada');
      }

      // TODO: Crear el modelo del producto y guardarlo usando el modelo correcto
      final nuevoProducto = ProductoInventario(
        id: _isEditing ? widget.productoId! : '', // Se generará en el backend
        appId: selectedApp.id,
        sku: _skuController.text.trim().isEmpty
            ? 'AUTO-${DateTime.now().millisecondsSinceEpoch}'
            : _skuController.text.trim(),
        nombre: _nombreController.text.trim(),
        descripcion: _descripcionController.text.trim().isEmpty
            ? null
            : _descripcionController.text.trim(),
        categoriaId: _selectedCategoriaId,
        unidadId: _selectedUnidadMedidaId,
        precioUnitario: _precioController.text.isEmpty
            ? null
            : double.parse(_precioController.text),
        activo: true,
        creadoEn: DateTime.now(),
        actualizadoEn: DateTime.now(),
      );
      if (_isEditing) {
        // TODO: Actualizar producto existente
        // await ref.read(productosInventarioProvider(selectedApp.id).notifier)
        //     .updateProducto(nuevoProducto);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Producto actualizado exitosamente')),
        );
      } else {
        // TODO: Crear nuevo producto
        // await ref.read(productosInventarioProvider(selectedApp.id).notifier)
        //     .createProducto(nuevoProducto);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Producto creado exitosamente')),
        );
      }

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
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

  // Métodos para manejar categorías y unidades de medida
  void _showCreateCategoriaDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Crear Categoría'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Nombre de la categoría',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                // TODO: Validar y guardar nombre
              },
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (value) {
                // TODO: Validar y guardar descripción
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Crear categoría
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Categoría creada exitosamente')),
              );
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  void _showEditCategoriaDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Categoría'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Nombre de la categoría',
                border: OutlineInputBorder(),
              ),
              // TODO: Cargar valores actuales
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              // TODO: Cargar valores actuales
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Actualizar categoría
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Categoría actualizada exitosamente')),
              );
            },
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }

  void _showCreateUnidadDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Crear Unidad de Medida'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Nombre de la unidad',
                hintText: 'ej: Kilogramo, Litro, Pieza',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Símbolo/Abreviación',
                hintText: 'ej: kg, L, pz',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Crear unidad de medida
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Unidad de medida creada exitosamente')),
              );
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  void _showEditUnidadDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Unidad de Medida'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Nombre de la unidad',
                border: OutlineInputBorder(),
              ),
              // TODO: Cargar valores actuales
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Símbolo/Abreviación',
                border: OutlineInputBorder(),
              ),
              // TODO: Cargar valores actuales
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              // TODO: Cargar valores actuales
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Actualizar unidad de medida
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Unidad de medida actualizada exitosamente')),
              );
            },
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }
}
