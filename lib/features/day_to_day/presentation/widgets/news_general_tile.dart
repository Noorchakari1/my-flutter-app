import 'package:flutter/material.dart';

import 'day_to_day_tile.dart';

/// Placeholder tile for the General news category in the "Day to Day" dashboard.
///
/// TODO: Replace with a live general news feed (features/news).
class NewsGeneralTile extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback? onTap;

  const NewsGeneralTile({
    super.key,
    required this.title,
    this.description = 'General news will appear here soon.',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => DayToDayTile(
        title: title,
        icon: Icons.newspaper,
        description: description,
        onTap: onTap,
      );
}