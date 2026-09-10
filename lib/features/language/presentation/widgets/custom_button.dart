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
      color: isGolden ? const Color(0xFF15130F) : isDarkMode ? const Color(0xFF211E34) : theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isGolden
                ? const Color(0xFFB08D57).withAlpha(110)
                : isDarkMode
                    ? Colors.white12
                    : const Color(0xFFE1E6F2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDarkMode ? 20 : 9),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 3,
                  child: flagAsset != null
                      ? Image.asset(flagAsset!, fit: BoxFit.contain)
                      : Container(
                          constraints: const BoxConstraints(maxWidth: 52, maxHeight: 52),
                          padding: const EdgeInsets.all(11),
                          decoration: BoxDecoration(
                            color: isGolden
                                ? const Color(0xFFB08D57).withAlpha(24)
                                : isDarkMode
                                    ? Colors.white.withAlpha(16)
                                    : theme.colorScheme.primary.withAlpha(14),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: FittedBox(
                            child: Icon(
                              iconData ?? Icons.error_outline_rounded,
                              color: isGolden ? const Color(0xFFB08D57) : isDarkMode ? Colors.white : theme.primaryColor,
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 6),
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
                        color: isGolden ? const Color(0xFFF7F1E3) : isDarkMode ? Colors.white : const Color(0xFF282D43),
                        fontSize: 12,
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
