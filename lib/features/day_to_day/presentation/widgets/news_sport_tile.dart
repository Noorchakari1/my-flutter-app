import 'package:flutter/material.dart';

import 'day_to_day_tile.dart';

/// Placeholder tile for the Sport news category in the "Day to Day" dashboard.
///
/// TODO: Replace with a live sports news feed (features/news).
class NewsSportTile extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback? onTap;

  const NewsSportTile({
    super.key,
    required this.title,
    this.description = 'Sports news will appear here soon.',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => DayToDayTile(
        title: title,
        icon: Icons.sports_soccer,
        description: description,
        onTap: onTap,
      );
}