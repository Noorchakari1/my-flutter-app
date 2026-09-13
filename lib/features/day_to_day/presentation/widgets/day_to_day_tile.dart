import 'package:flutter/material.dart';

/// Shared card used by every tile of the "Day to Day" dashboard.
///
/// Each module in the dashboard is a separate `.dart` file that builds on this
/// base (e.g. [WeatherTile], [ExchangeRateTile], ...). This keeps the tile
/// styling in one place while letting developers replace individual tiles with
/// their real implementations later.
class DayToDayTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final String description;
  final VoidCallback? onTap;

  const DayToDayTile({
    super.key,
    required this.title,
    required this.icon,
    this.description = '',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final isGolden = theme.colorScheme.primary == const Color(0xFFB08D57);

    return Material(
      color: isGolden
          ? const Color(0xFF15130F)
          : isDarkMode
              ? const Color(0xFF211E34)
              : theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isGolden
                ? const Color(0xFFB08D57).withAlpha(190)
                : isDarkMode
                    ? Colors.white30
                    : const Color(0xFFE1E6F2),
            width: 1.1,
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
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
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
                      icon,
                      size: 26,
                      color: isGolden
                          ? const Color(0xFFB08D57)
                          : isDarkMode
                              ? Colors.white
                              : theme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isGolden
                        ? const Color(0xFFF7F1E3)
                        : isDarkMode
                            ? Colors.white
                            : const Color(0xFF282D43),
                    fontSize: 13,
                  ),
                ),
                if (description != '')
                  const SizedBox(height: 4),
                if (description != '')
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isGolden
                          ? const Color(0xFFF7F1E3).withAlpha(170)
                          : isDarkMode
                              ? Colors.white.withAlpha(179)
                              : const Color(0xFF5B6070),
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