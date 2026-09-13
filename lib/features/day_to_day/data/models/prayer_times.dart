class PrayerTimes {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final bool isOfficialTableEntry;

  const PrayerTimes({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    this.isOfficialTableEntry = false,
  });

  factory PrayerTimes.fromJson(Map<String, dynamic> json) {
    String time(String key) {
      final value = json[key];
      if (value is! String ||
          !RegExp(r'^(?:[01]\d|2[0-3]):[0-5]\d$').hasMatch(value)) {
        throw FormatException('Invalid prayer time: $key');
      }
      return value;
    }

    return PrayerTimes(
      fajr: time('fajr'),
      sunrise: time('sunrise'),
      dhuhr: time('dhuhr'),
      asr: time('asr'),
      maghrib: time('maghrib'),
      isha: time('isha'),
      isOfficialTableEntry: true,
    );
  }
}
