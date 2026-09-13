import 'package:flutter/material.dart';

import 'day_to_day_tile.dart';

/// Placeholder tile for the Other news categories in the "Day to Day" dashboard.
///
/// TODO: Replace with live news rounded up from the remaining categories
/// (social, economic, political, cultural ...) via (features/news).
class NewsOthersTile extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback? onTap;

  const NewsOthersTile({
    super.key,
    required this.title,
    this.description = 'More news categories will appear here soon.',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => DayToDayTile(
        title: title,
        icon: Icons.more_horiz,
        description: description,
        onTap: onTap,
      );
}