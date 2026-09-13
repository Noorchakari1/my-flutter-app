import 'dart:io';

import 'package:aop_sites/core/utils/calendar_converter.dart';
import 'package:aop_sites/features/day_to_day/data/services/prayer_times_repository.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class TimetableBundle extends CachingAssetBundle {
  int loads = 0;
  bool fail = false;

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    loads++;
    if (fail) throw StateError('Unavailable');
    return File(key).readAsString();
  }

  @override
  Future<ByteData> load(String key) => throw UnimplementedError();
}

void main() {
  test('looks up permanent Shamsi dates and shares one load', () async {
    final bundle = TimetableBundle();
    final repository = PrayerTimesRepository(bundle: bundle);
    for (final year in [1404, 1405, 1406]) {
      final times = await repository.forGregorianDate(
        CalendarConverter.solarHijriToGregorian(CalendarDate(year, 6, 22)),
      );
      expect(times.fajr, '04:09');
      expect(times.isha, '19:28');
      expect(times.isOfficialTableEntry, isTrue);
    }
    expect(bundle.loads, 1);
  });

  test('every day including leap day exists', () async {
    final repository = PrayerTimesRepository(bundle: TimetableBundle());
    final start =
        CalendarConverter.solarHijriToGregorian(const CalendarDate(1403, 1, 1));
    for (var day = 0; day < 366; day++) {
      final times =
          await repository.forGregorianDate(start.add(Duration(days: day)));
      expect(times.isOfficialTableEntry, isTrue);
    }
  });

  test('failed loading can be retried', () async {
    final bundle = TimetableBundle()..fail = true;
    final repository = PrayerTimesRepository(bundle: bundle);
    await expectLater(
        repository.forGregorianDate(DateTime(2026, 9, 13)), throwsStateError);
    bundle.fail = false;
    expect((await repository.forGregorianDate(DateTime(2026, 9, 13))).fajr,
        '04:09');
    expect(bundle.loads, 2);
  });
}
