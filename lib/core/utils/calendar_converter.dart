import 'package:shamsi_date/shamsi_date.dart';

/// A date expressed in one of the calendars displayed by the app.
class CalendarDate {
  final int year;
  final int month;
  final int day;

  const CalendarDate(this.year, this.month, this.day);

  @override
  String toString() => '$year/${month.toString().padLeft(2, '0')}/${day.toString().padLeft(2, '0')}';
}

/// Converts between Gregorian, Solar Hijri and tabular Islamic (Qamari) dates.
///
/// Qamari dates use the civil/tabular calendar.  Official moon-sighting dates
/// can differ by one day, so this is deliberately presented as a converter and
/// not used to determine religious observances.
class CalendarConverter {
  static final DateTime _islamicEpoch = DateTime.utc(622, 7, 19);
  static final DateTime _minimumSupportedGregorian = DateTime(560, 3, 20);
  static final DateTime _maximumSupportedGregorian = DateTime(3798, 12, 31);

  /// `shamsi_date` can only calculate dates in this inclusive range.
  /// Checking it here keeps package exceptions out of the presentation layer.
  static bool isSupportedGregorian(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    return !dateOnly.isBefore(_minimumSupportedGregorian) &&
        !dateOnly.isAfter(_maximumSupportedGregorian);
  }

  static CalendarDate toSolarHijri(DateTime gregorian) {
    _requireSupportedGregorian(gregorian);
    final date = Jalali.fromDateTime(gregorian);
    return CalendarDate(date.year, date.month, date.day);
  }

  static DateTime solarHijriToGregorian(CalendarDate date) {
    final gregorian = Jalali(date.year, date.month, date.day).toDateTime();
    _requireSupportedGregorian(gregorian);
    return gregorian;
  }

  static CalendarDate toQamari(DateTime gregorian) {
    _requireSupportedGregorian(gregorian);
    final target = _dateOnlyUtc(gregorian);
    // A close lower bound makes the following small, deterministic search
    // straightforward and avoids fragile Julian-day floating point maths.
    var year = ((target.difference(_islamicEpoch).inDays / 354.367).floor() + 1)
        .clamp(1, 9999)
        .toInt();
    while (_qamariToGregorian(year + 1, 1, 1).isBefore(target) ||
        _qamariToGregorian(year + 1, 1, 1).isAtSameMomentAs(target)) {
      year++;
    }
    while (_qamariToGregorian(year, 1, 1).isAfter(target)) {
      year--;
    }
    var month = 1;
    while (month < 12 &&
        (_qamariToGregorian(year, month + 1, 1).isBefore(target) ||
            _qamariToGregorian(year, month + 1, 1).isAtSameMomentAs(target))) {
      month++;
    }
    final day = target.difference(_qamariToGregorian(year, month, 1)).inDays + 1;
    return CalendarDate(year, month, day);
  }

  static DateTime qamariToGregorian(CalendarDate date) {
    final utcDate = _qamariToGregorian(date.year, date.month, date.day);
    // Preserve the calendar day on devices in every time zone.
    final gregorian = DateTime(utcDate.year, utcDate.month, utcDate.day);
    _requireSupportedGregorian(gregorian);
    return gregorian;
  }

  static DateTime _qamariToGregorian(int year, int month, int day) {
    if (year < 1 || month < 1 || month > 12 || day < 1 || day > 30) {
      throw ArgumentError('Invalid Qamari date');
    }
    final result = _qamariDateAtStartOfDay(year, month, day);
    final followingMonth = _qamariDateAtStartOfDay(
      month == 12 ? year + 1 : year,
      month == 12 ? 1 : month + 1,
      1,
    );
    if (!result.isBefore(followingMonth)) {
      throw ArgumentError('Invalid Qamari date');
    }
    return result;
  }

  static DateTime _qamariDateAtStartOfDay(int year, int month, int day) {
    final days = (year - 1) * 354 +
        ((3 + 11 * year) ~/ 30) +
        ((29.5 * (month - 1)).ceil()) +
        day -
        1;
    return _islamicEpoch.add(Duration(days: days));
  }

  static DateTime _dateOnlyUtc(DateTime date) =>
      DateTime.utc(date.year, date.month, date.day);

  static void _requireSupportedGregorian(DateTime date) {
    if (!isSupportedGregorian(date)) {
      throw const FormatException('Date is outside the supported calendar range.');
    }
  }
}
