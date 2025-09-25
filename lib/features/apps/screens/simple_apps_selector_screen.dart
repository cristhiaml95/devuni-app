import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Versión simplificada del selector de Apps para debug
class SimpleAppsSelectorScreen extends ConsumerWidget {
  const SimpleAppsSelectorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Apps Selector - Versión Simple',
              style: AppTypography.headlineLarge.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Esta es una versión simplificada para debug',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                print('🐛 DEBUG: Botón presionado en SimpleAppsSelectorScreen');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Test Button'),
            ),
          ],
        ),
      ),
    );
  }
}
