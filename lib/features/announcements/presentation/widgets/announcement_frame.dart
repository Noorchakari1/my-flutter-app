import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/theme_provider.dart';
import '../../data/providers/announcement_provider.dart';

/// A formal, responsive card for an official announcement.
class OfficialAnnouncementCard extends StatelessWidget {
  static const issuer =
      '\u062f \u0639\u0627\u0644\u06cc\u0642\u062f\u0631 \u0627\u0645\u06cc\u0631 \u0627\u0644\u0645\u0624\u0645\u0646\u06cc\u0646 \u062d\u0641\u0638\u0647 \u0627\u0644\u0644\u0647 \u062a\u0639\u0627\u0644\u06cc';

  final String description;
  final String sender;
  final String themeVariant;
  final VoidCallback? onTap;

  const OfficialAnnouncementCard({
    super.key,
    required this.description,
    this.sender = issuer,
    required this.themeVariant,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = _AnnouncementPalette.forVariant(themeVariant);

    return Semantics(
      button: onTap != null,
      label: 'Official announcement',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Ink(
            decoration: BoxDecoration(
              color: palette.backdrop,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(themeVariant == 'light' ? 28 : 55),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: AspectRatio(
                aspectRatio: 3277 / 2325,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ColorFiltered(
                      // Soft ivory keeps light mode from becoming stark white.
                      colorFilter: ColorFilter.mode(palette.frameTint, BlendMode.multiply),
                      child: Image.asset(palette.asset, fit: BoxFit.fill),
                    ),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Stack(
                          children: [
                            // These fixed boxes ensure the sender never moves
                            // when the main announcement contains more text.
                            Positioned(
                              left: constraints.maxWidth * .135,
                              right: constraints.maxWidth * .135,
                              top: constraints.maxHeight * .285,
                              height: constraints.maxHeight * .385,
                              child: _AutoFittingText(
                                text: description,
                                color: palette.text,
                                maxFontSize: 19,
                                minFontSize: 4.5,
                                fontWeight: FontWeight.w600,
                                lineHeight: 1.42,
                              ),
                            ),
                            Positioned(
                              left: constraints.maxWidth * .15,
                              right: constraints.maxWidth * .15,
                              top: constraints.maxHeight * .73,
                              height: constraints.maxHeight * .075,
                              child: _AutoFittingText(
                                text: sender,
                                color: palette.issuer,
                                maxFontSize: 11.5,
                                minFontSize: 4.5,
                                fontWeight: FontWeight.w600,
                                lineHeight: 1.2,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

}

/// Finds the largest font size that keeps every line inside its fixed box.
class _AutoFittingText extends StatelessWidget {
  final String text;
  final Color color;
  final double maxFontSize;
  final double minFontSize;
  final FontWeight fontWeight;
  final double lineHeight;
  final int? maxLines;

  const _AutoFittingText({
    required this.text,
    required this.color,
    required this.maxFontSize,
    required this.minFontSize,
    required this.fontWeight,
    required this.lineHeight,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fontSize = _fontSizeThatFits(constraints);
        return Center(
          child: Text(
            text,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            softWrap: true,
            maxLines: maxLines,
            style: TextStyle(
              color: color,
              fontSize: fontSize,
              fontWeight: fontWeight,
              height: lineHeight,
            ),
          ),
        );
      },
    );
  }

  double _fontSizeThatFits(BoxConstraints constraints) {
    var low = minFontSize;
    var high = maxFontSize;

    for (var iteration = 0; iteration < 18; iteration++) {
      final candidate = (low + high) / 2;
      final painter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(fontSize: candidate, fontWeight: fontWeight, height: lineHeight),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
        maxLines: maxLines,
      )..layout(maxWidth: constraints.maxWidth);

      final fits = painter.height <= constraints.maxHeight && !painter.didExceedMaxLines;
      if (fits) {
        low = candidate;
      } else {
        high = candidate;
      }
    }
    return low;
  }
}

class _AnnouncementPalette {
  final String asset;
  final Color backdrop;
  final Color frameTint;
  final Color text;
  final Color issuer;

  const _AnnouncementPalette({
    required this.asset,
    required this.backdrop,
    required this.frameTint,
    required this.text,
    required this.issuer,
  });

  factory _AnnouncementPalette.forVariant(String variant) => switch (variant) {
        'dark' => const _AnnouncementPalette(
            asset: 'assets/frames/dark.png', backdrop: Color(0xFF0B2340), frameTint: Colors.white,
            text: Color(0xFFF9F6EF), issuer: Color(0xFFE6C16C)),
        'golden' => const _AnnouncementPalette(
            asset: 'assets/frames/golden.png', backdrop: Color(0xFF31220D), frameTint: Colors.white,
            text: Color(0xFF2E210D), issuer: Color(0xFF5F4212)),
        _ => const _AnnouncementPalette(
            asset: 'assets/frames/light.png', backdrop: Color(0xFFF1EADD), frameTint: Color(0xFFF3E9D8),
            text: Color(0xFF2D261D), issuer: Color(0xFF76551E)),
      };
}

/// Provider-driven version for screens that display the latest announcement.
class AnnouncementFrame extends ConsumerWidget {
  final String language;

  const AnnouncementFrame({super.key, required this.language});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcement = ref.watch(latestAnnouncementProvider(language));
    final variant = ref.watch(themeNotifierProvider).themeVariant;
    return announcement.when(
      loading: () => _statusCard('Loading the latest announcement...', variant),
      error: (_, __) => _statusCard('Unable to load the latest announcement.', variant),
      data: (item) => OfficialAnnouncementCard(description: item.description, themeVariant: variant),
    );
  }

  Widget _statusCard(String message, String variant) =>
      OfficialAnnouncementCard(description: message, themeVariant: variant);
}
