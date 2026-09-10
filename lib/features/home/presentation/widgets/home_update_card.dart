import 'package:flutter/material.dart';

/// Visual style resolved from the active application theme for home updates.
class HomeUpdateCardTheme {
  final Color background;
  final Color surface;
  final Color primary;
  final Color accent;
  final Color text;
  final Color mutedText;
  final Color sourceBackground;

  const HomeUpdateCardTheme({
    required this.background,
    required this.surface,
    required this.primary,
    required this.accent,
    required this.text,
    required this.mutedText,
    required this.sourceBackground,
  });
}

/// A two-part official-update card with message and source/signature areas.
class HomeUpdateCard extends StatelessWidget {
  final HomeUpdateCardTheme theme;
  final String category;
  final String title;
  final String description;
  final String actionLabel;
  final String source;
  final IconData icon;
  final bool isLive;
  final VoidCallback onAction;

  const HomeUpdateCard({
    super.key,
    required this.theme,
    required this.category,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.source,
    required this.icon,
    required this.onAction,
    this.isLive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.accent.withAlpha(120)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(30),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned(
                    top: -34,
                    right: -22,
                    child: Icon(icon, size: 130, color: theme.primary.withAlpha(14)),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _CategoryBadge(label: category, theme: theme),
                            if (isLive) ...[
                              const SizedBox(width: 8),
                              const _LiveIndicator(),
                            ],
                          ],
                        ),
                        const Spacer(),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: theme.background,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(icon, color: theme.primary, size: 21),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: theme.text,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          description,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.start,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: theme.mutedText, fontSize: 13, height: 1.45),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 38,
                          child: ElevatedButton.icon(
                            onPressed: onAction,
                            icon: Icon(isLive ? Icons.play_circle_fill_rounded : Icons.arrow_forward_rounded, size: 18),
                            label: Text(actionLabel),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
              decoration: BoxDecoration(
                color: theme.sourceBackground,
                border: Border(top: BorderSide(color: theme.accent.withAlpha(90))),
              ),
              child: Row(
                children: [
                  Icon(Icons.draw_outlined, size: 17, color: theme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      source,
                      textDirection: TextDirection.rtl,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: theme.mutedText, fontSize: 11, fontWeight: FontWeight.w600, height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final String label;
  final HomeUpdateCardTheme theme;

  const _CategoryBadge({required this.label, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: theme.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.accent.withAlpha(150)),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(color: theme.primary, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: .7),
      ),
    );
  }
}

class _LiveIndicator extends StatelessWidget {
  const _LiveIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(color: const Color(0xFFE53935), borderRadius: BorderRadius.circular(20)),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, color: Colors.white, size: 7),
          SizedBox(width: 5),
          Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: .7)),
        ],
      ),
    );
  }
}
