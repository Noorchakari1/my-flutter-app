import 'package:flutter/material.dart';

import '../../../../core/config/routes.dart';

import 'day_to_day_tile.dart';

/// Opens the full weather feature from the Day to Day dashboard.
class WeatherTile extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback? onTap;

  const WeatherTile({
    super.key,
    required this.title,
    this.description = '',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => DayToDayTile(
        title: title,
        icon: Icons.cloud,
        description: description,
        onTap: onTap ?? () => Navigator.of(context).pushNamed(Routes.weather),
      );
}
