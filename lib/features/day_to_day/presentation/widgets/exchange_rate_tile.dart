import 'package:flutter/material.dart';

import 'day_to_day_tile.dart';

/// Placeholder tile for the Exchange Rate module in the "Day to Day" dashboard.
///
/// TODO: Replace with the real currency exchange widget/service.
class ExchangeRateTile extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback? onTap;

  const ExchangeRateTile({
    super.key,
    required this.title,
    this.description = 'Exchange rate details will appear here soon.',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => DayToDayTile(
        title: title,
        icon: Icons.currency_exchange,
        description: description,
        onTap: onTap,
      );
}