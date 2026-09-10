import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/theme_provider.dart';
import '../../../announcements/data/models/announcement.dart';
import '../../../announcements/data/providers/announcement_provider.dart';
import '../../../announcements/presentation/widgets/announcement_frame.dart';

/// Swipeable set of official home-screen updates: live, announcement, and orders.
class HomeUpdatesCarousel extends ConsumerStatefulWidget {
  final String language;

  const HomeUpdatesCarousel({super.key, required this.language});

  @override
  ConsumerState<HomeUpdatesCarousel> createState() => _HomeUpdatesCarouselState();
}

class _HomeUpdatesCarouselState extends ConsumerState<HomeUpdatesCarousel> {
  final PageController _controller = PageController(viewportFraction: .92);
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeNotifierProvider);
    final announcement = ref.watch(latestAnnouncementProvider(widget.language));
    final indicatorColor = _indicatorColor(themeState.themeVariant);

    return SizedBox(
      height: 284,
      child: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _controller,
              padEnds: false,
              onPageChanged: (page) => setState(() => _currentPage = page),
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 8),
                  child: OfficialAnnouncementCard(
                    description: 'Official live broadcasts from the General Directorate of Administration will appear here.',
                    sender: 'LIVE STREAMING',
                    themeVariant: themeState.themeVariant,
                    onTap: () => _showComingSoon(context, 'Live streaming will be available soon.'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: announcement.when(
                    loading: () => _loadingCard(themeState.themeVariant),
                    error: (_, __) => _errorCard(themeState.themeVariant),
                    data: (item) => _announcementCard(themeState.themeVariant, item),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 16),
                  child: OfficialAnnouncementCard(
                    description: 'New official orders and decrees will be published in this section.',
                    sender: 'OFFICIAL ORDERS',
                    themeVariant: themeState.themeVariant,
                    onTap: () => _showComingSoon(context, 'Official orders will be available soon.'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 18 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: _currentPage == index ? indicatorColor : indicatorColor.withAlpha(55),
                borderRadius: BorderRadius.circular(8),
              ),
            )),
          ),
        ],
      ),
    );
  }

  Widget _announcementCard(String themeVariant, Announcement item) {
    return OfficialAnnouncementCard(
      description: item.description,
      themeVariant: themeVariant,
    );
  }

  Widget _loadingCard(String themeVariant) => OfficialAnnouncementCard(
    description: 'Please wait while the latest official announcement is loaded.',
    themeVariant: themeVariant,
  );

  Widget _errorCard(String themeVariant) => OfficialAnnouncementCard(
    description: 'The latest announcement could not be loaded. Tap to try again.',
    themeVariant: themeVariant,
    onTap: () => ref.invalidate(latestAnnouncementProvider(widget.language)),
  );

  void _showComingSoon(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Color _indicatorColor(String variant) => switch (variant) {
        'dark' => const Color(0xFFE6BB56),
        'golden' => const Color(0xFFB08D57),
        _ => const Color(0xFF1B047C),
      };
}
