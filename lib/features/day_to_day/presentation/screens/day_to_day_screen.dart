import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/theme_provider.dart';
import '../../../../shared/constants/app_constants.dart';
import '../widgets/day_to_day_tile.dart';
import '../widgets/exchange_rate_tile.dart';
import '../widgets/news_general_tile.dart';
import '../widgets/news_others_tile.dart';
import '../widgets/news_sport_tile.dart';
import '../widgets/prayer_time_tile.dart';
import '../widgets/qibla_tile.dart';
import '../widgets/weather_tile.dart';
import 'date_converter_screen.dart';

/// "Day to Day" dashboard tab: a grid of daily-use modules.
///
/// Every module in the grid lives in its own file under
/// `presentation/widgets/` so individual tiles can be replaced with their real
/// implementations later without touching this screen.
class DayToDayScreen extends ConsumerStatefulWidget {
  const DayToDayScreen({super.key});

  @override
  ConsumerState<DayToDayScreen> createState() => _DayToDayScreenState();
}

class _DayToDayScreenState extends ConsumerState<DayToDayScreen> {
  // Helper function to get localized text
  String _getText(String key) {
    final language = ref.watch(themeNotifierProvider).currentLanguage;
    Map<String, String> textMap;
    switch (language) {
      case 'pashto':
        textMap = AppConstants.pashtoText;
        break;
      case 'persian':
        textMap = AppConstants.persianText;
        break;
      default:
        textMap = AppConstants.englishText;
    }
    return textMap[key] ?? key; // Return key if translation not found
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const gap = 12.0;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
        children: [
          Text(
            _getText('dayToDay'),
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            _getText('dayToDayDescription'),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          // Daily tools open their full feature screens; upcoming modules
          // retain their coming-soon labels.
          GridView.count(
            // This grid is inside the parent ListView. Without shrinkWrap it
            // tries to grow to an infinite height and Flutter throws a layout
            // exception when the Day-to-Day tab is built.
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: gap,
            crossAxisSpacing: gap,
            childAspectRatio: 1.15,
            children: [
              WeatherTile(
                title: _getText('weather'),
              ),
              ExchangeRateTile(
                title: _getText('exchangeRate'),
                description: _getText('comingSoon'),
              ),
              NewsSportTile(
                title: _getText('newsTabsSports'),
                description: _getText('comingSoon'),
              ),
              NewsGeneralTile(
                title: _getText('newsTabsGeneral'),
                description: _getText('comingSoon'),
              ),
              NewsOthersTile(
                title: _getText('newsTabsOthers'),
                description: _getText('comingSoon'),
              ),
              QiblaTile(
                title: _getText('qiblaCompass'),
              ),
              PrayerTimeTile(
                title: _getText('prayerTime'),
                description: _getText('dailyPrayerTimes'),
              ),
              DayToDayTile(
                title: _getText('dateConverter'),
                icon: Icons.calendar_month_outlined,
                description: _getText('dateConverterShortDescription'),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const DateConverterScreen()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
