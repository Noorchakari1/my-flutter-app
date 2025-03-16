import 'package:flutter/material.dart';
import '../../../../shared/constants/app_constants.dart';

class PageLoadingIndicator extends StatelessWidget {
  final bool isLoading;
  final double progress;

  const PageLoadingIndicator({
    super.key,
    required this.isLoading,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading && progress >= 1.0) return const SizedBox.shrink();
    
    return Stack(
      children: [
        if (progress < 1.0)
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              AppConstants.primaryColor,
            ),
          ),
        if (isLoading)
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
} 