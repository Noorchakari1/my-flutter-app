import 'package:flutter/material.dart';
import '../../../../shared/constants/app_constants.dart';

class DownloadProgressIndicator extends StatelessWidget {
  final bool isDownloading;
  final double downloadProgress;
  final String? fileName;

  const DownloadProgressIndicator({
    super.key,
    required this.isDownloading,
    required this.downloadProgress,
    this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    if (!isDownloading) return const SizedBox.shrink();
    
    return Container(
      color: Colors.black54,
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  fileName ?? 'Downloading...',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                CircularProgressIndicator(
                  value: downloadProgress,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppConstants.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(downloadProgress * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 