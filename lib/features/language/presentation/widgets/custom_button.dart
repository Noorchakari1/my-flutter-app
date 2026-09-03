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
    final isGolden = theme.colorScheme.primary == const Color(0xFFB08D57);

    return Material(
      color: isGolden ? const Color(0xFF15130F) : isDarkMode ? const Color(0xFF211E34) : Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isGolden ? const Color(0xFFB08D57).withAlpha(110) : isDarkMode ? Colors.white12 : theme.colorScheme.primary.withAlpha(18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDarkMode ? 20 : 13),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
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
                          color: isGolden ? const Color(0xFFB08D57) : isDarkMode ? Colors.white : theme.primaryColor,
                          size: 28,
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
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isGolden ? const Color(0xFFF7F1E3) : isDarkMode ? Colors.white : Colors.black87,
                        fontSize: 13,
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
