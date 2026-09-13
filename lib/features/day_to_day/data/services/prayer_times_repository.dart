import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../../core/utils/calendar_converter.dart';
import '../models/prayer_times.dart';

/// Permanent Kabul timetable, indexed by Solar Hijri month and day.
class PrayerTimesRepository {
  static const assetPath =
      'lib/features/announcements/data/kabul_prayer_times_permanent.json';
  static final PrayerTimesRepository _shared =
      PrayerTimesRepository._(rootBundle);

  factory PrayerTimesRepository({AssetBundle? bundle}) =>
      bundle == null ? _shared : PrayerTimesRepository._(bundle);

  PrayerTimesRepository._(this._bundle);
  final AssetBundle _bundle;
  Future<Map<String, PrayerTimes>>? _table;

  Future<PrayerTimes> forGregorianDate(DateTime date) async {
    final shamsi = CalendarConverter.toSolarHijri(date);
    final table = await (_table ??= _loadTable());
    final key =
        '${shamsi.month.toString().padLeft(2, '0')}-${shamsi.day.toString().padLeft(2, '0')}';
    final times = table[key];
    if (times == null) {
      throw FormatException('Missing Kabul timetable day: $key');
    }
    return times;
  }

  Future<Map<String, PrayerTimes>> _loadTable() async {
    try {
      final json = jsonDecode(await _bundle.loadString(assetPath))
          as Map<String, dynamic>;
      return json.map((key, value) => MapEntry(
            key,
            PrayerTimes.fromJson(value as Map<String, dynamic>),
          ));
    } catch (_) {
      _table = null; // Allow retry after a failed asset load.
      rethrow;
    }
  }
}
