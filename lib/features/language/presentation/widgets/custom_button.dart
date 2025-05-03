import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final String? flagAsset;
  final IconData? iconData;

  const CustomButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.flagAsset,
    this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    
    return AspectRatio(
      aspectRatio: 1,
      child: Material(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 4,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 3,
                  child: flagAsset != null
                    ? Image.asset(
                        flagAsset!,
                        fit: BoxFit.contain,
                      )
                    : FittedBox(
                        fit: BoxFit.contain,
                        child: Icon(
                          iconData ?? Icons.error,
                          color: isDarkMode ? Colors.white : theme.primaryColor,
                          size: 20,
                        ),
                      ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 