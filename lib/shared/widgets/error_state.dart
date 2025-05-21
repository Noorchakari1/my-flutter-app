import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/localization_helper.dart';

/// Widget for displaying an error state with retry button
class ErrorState extends ConsumerWidget {
  final dynamic error;
  final VoidCallback onRetry;
  
  const ErrorState({
    super.key,
    required this.error,
    required this.onRetry,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              child: Text(LocalizationHelper.getText(ref, 'tryAgain')),
            ),
          ],
        ),
      ),
    );
  }
}
