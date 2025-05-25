import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'localization_helper.dart';

/// Solar Hijri (Persian) Calendar utility class
/// Uses shamsi_date package for accurate date conversions
class SolarHijriCalendar {
  /// Get localized month name
  static String getLocalizedMonthName(int month, WidgetRef ref) {
    final monthKeys = [
      'hamal', 'sawr', 'jawza', 'saratan', 'asad', 'sunbula',
      'mizan', 'aqrab', 'qaws', 'jadi', 'dalw', 'hut'
    ];

    if (month < 1 || month > 12) return '';

    return LocalizationHelper.getText(ref, monthKeys[month - 1]);
  }

  /// Format Jalali date as localized string
  static String formatJalaliDate(Jalali date, WidgetRef ref) {
    final monthName = getLocalizedMonthName(date.month, ref);
    return '${date.day} $monthName ${date.year}';
  }

  /// Convert Gregorian date string to localized Solar Hijri format
  static String? formatGregorianDateToSolarHijri(String? gregorianDateString, WidgetRef ref) {
    if (gregorianDateString == null || gregorianDateString.isEmpty) return null;

    try {
      final gregorianDate = DateTime.parse(gregorianDateString);
      final jalaliDate = Jalali.fromDateTime(gregorianDate);
      return formatJalaliDate(jalaliDate, ref);
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
