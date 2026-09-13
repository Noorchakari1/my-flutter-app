import 'package:flutter/material.dart';

import '../screens/prayer_times_screen.dart';
import 'day_to_day_tile.dart';

class PrayerTimeTile extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback? onTap;

  const PrayerTimeTile({
    super.key,
    required this.title,
    this.description = 'View daily prayer times.',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => DayToDayTile(
        title: title,
        icon: Icons.access_time_filled,
        description: description,
        onTap: onTap ?? () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PrayerTimesScreen()),
        ),
      );
}
