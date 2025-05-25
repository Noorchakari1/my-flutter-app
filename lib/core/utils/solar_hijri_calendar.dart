import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'localization_helper.dart';

/// Solar Hijri (Persian) Calendar utility class
/// Converts Gregorian dates to Solar Hijri calendar format
class SolarHijriCalendar {
  /// Convert Gregorian date to Solar Hijri date
  static SolarHijriDate gregorianToSolarHijri(DateTime gregorianDate) {
    int gy = gregorianDate.year;
    int gm = gregorianDate.month;
    int gd = gregorianDate.day;

    // Conversion algorithm from Gregorian to Solar Hijri
    int jy, jm, jd;
    
    // Calculate Julian day number
    int gDM = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334][gm - 1];
    if (gm > 2) {
      gDM += _isLeapYear(gy) ? 1 : 0;
    }
    
    int jdG = 365 * gy + ((gy + 3) ~/ 4) - ((gy + 99) ~/ 100) + ((gy + 399) ~/ 400) - 80 + gd + gDM;
    
    // Convert to Solar Hijri
    jy = -14;
    int jp = jdG - 79;
    
    while (jp >= 0) {
      jy++;
      int jLeap = _isSolarHijriLeapYear(jy) ? 1 : 0;
      jp -= 365 + jLeap;
      if (jp < 0) {
        jp += 365 + jLeap;
        break;
      }
    }
    
    if (jp < 186) {
      jm = 1 + (jp ~/ 31);
      jd = 1 + (jp % 31);
    } else {
      jm = 7 + ((jp - 186) ~/ 30);
      jd = 1 + ((jp - 186) % 30);
    }
    
    return SolarHijriDate(year: jy, month: jm, day: jd);
  }

  /// Check if a Gregorian year is leap year
  static bool _isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  /// Check if a Solar Hijri year is leap year
  static bool _isSolarHijriLeapYear(int year) {
    // Simplified leap year calculation for Solar Hijri
    int cycle = year % 128;
    return [1, 5, 9, 13, 17, 22, 26, 30, 34, 38, 42, 46, 50, 55, 59, 63, 67, 71, 75, 79, 83, 88, 92, 96, 100, 104, 108, 112, 116, 121, 125].contains(cycle);
  }

  /// Get localized month name
  static String getLocalizedMonthName(int month, WidgetRef ref) {
    final monthKeys = [
      'hamal', 'sawr', 'jawza', 'saratan', 'asad', 'sunbula',
      'mizan', 'aqrab', 'qaws', 'jadi', 'dalw', 'hut'
    ];
    
    if (month < 1 || month > 12) return '';
    
    return LocalizationHelper.getText(ref, monthKeys[month - 1]);
  }

  /// Format Solar Hijri date as localized string
  static String formatSolarHijriDate(SolarHijriDate date, WidgetRef ref) {
    final monthName = getLocalizedMonthName(date.month, ref);
    return '${date.day} $monthName ${date.year}';
  }

  /// Convert Gregorian date string to localized Solar Hijri format
  static String? formatGregorianDateToSolarHijri(String? gregorianDateString, WidgetRef ref) {
    if (gregorianDateString == null || gregorianDateString.isEmpty) return null;
    
    try {
      final gregorianDate = DateTime.parse(gregorianDateString);
      final solarHijriDate = gregorianToSolarHijri(gregorianDate);
      return formatSolarHijriDate(solarHijriDate, ref);
    } catch (e) {
      return gregorianDateString; // Return original if parsing fails
    }
  }

  /// Get contract type localized text
  static String getLocalizedContractType(String? contractType, WidgetRef ref) {
    if (contractType == null || contractType.isEmpty) return '';
    
    // Map common contract type values to localization keys
    final contractTypeKey = contractType.toLowerCase();
    
    // Try to get localized text, fallback to original if not found
    final localizedText = LocalizationHelper.getText(ref, contractTypeKey);
    
    // If localization key not found, return the original text with proper capitalization
    if (localizedText == contractTypeKey) {
      return contractType.split(' ').map((word) => 
        word.isNotEmpty ? word[0].toUpperCase() + word.substring(1).toLowerCase() : word
      ).join(' ');
    }
    
    return localizedText;
  }
}

/// Solar Hijri date representation
class SolarHijriDate {
  final int year;
  final int month;
  final int day;

  const SolarHijriDate({
    required this.year,
    required this.month,
    required this.day,
  });

  @override
  String toString() => '$year/$month/$day';
}
