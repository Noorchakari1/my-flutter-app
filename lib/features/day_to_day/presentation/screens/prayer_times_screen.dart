import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/calendar_converter.dart';
import '../../../../core/utils/localization_helper.dart';
import '../../data/models/prayer_times.dart';
import '../../data/services/prayer_times_repository.dart';

class PrayerTimesScreen extends ConsumerStatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  ConsumerState<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends ConsumerState<PrayerTimesScreen> {
  final _repository = PrayerTimesRepository();
  late DateTime _selectedDate;
  late Future<PrayerTimes> _times;
  Timer? _clockTimer;

  @override
  void initState() {
    super.initState();
    final now = _kabulNow();
    _selectedDate = CalendarConverter.isSupportedGregorian(now)
        ? now
        : DateTime(2026, 1, 1);
    _times = _repository.forGregorianDate(_selectedDate);
    _clockTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  void _setDate(DateTime value) {
    setState(() {
      _selectedDate = DateTime(value.year, value.month, value.day);
      _times = _repository.forGregorianDate(_selectedDate);
    });
  }

  Future<void> _pickGregorianDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(560, 3, 20),
      lastDate: DateTime(3798, 12, 31),
    );
    if (mounted && picked != null) _setDate(picked);
  }

  Future<void> _enterShamsiDate() async {
    final controller = TextEditingController(
        text: CalendarConverter.toSolarHijri(_selectedDate).toString());
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LocalizationHelper.getText(ref, 'selectShamsiDate')),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.datetime,
          decoration: const InputDecoration(hintText: '1405/01/01'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(LocalizationHelper.getText(ref, 'cancel'))),
          FilledButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: Text(LocalizationHelper.getText(ref, 'showTimes'))),
        ],
      ),
    );
    if (!mounted || value == null) return;
    final parts = value.trim().split('/');
    try {
      if (parts.length != 3) throw const FormatException();
      _setDate(CalendarConverter.solarHijriToGregorian(CalendarDate(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      )));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  LocalizationHelper.getText(ref, 'validShamsiDateError'))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final shamsi = CalendarConverter.toSolarHijri(_selectedDate);
    final qamari = CalendarConverter.toQamari(_selectedDate);
    final baseTheme = Theme.of(context);
    // Derive accessible accent pairs even when the app overrides dark primary.
    final scheme = ColorScheme.fromSeed(
      seedColor: baseTheme.primaryColor,
      brightness: baseTheme.brightness,
      surface: baseTheme.colorScheme.surface,
    );
    return Theme(
      data: baseTheme.copyWith(colorScheme: scheme),
      child: Builder(
          builder: (context) => Scaffold(
                appBar: AppBar(
                    backgroundColor: scheme.surface,
                    foregroundColor: scheme.onSurface,
                    centerTitle: true,
                    titleTextStyle: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: scheme.onSurface),
                    title:
                        Text(LocalizationHelper.getText(ref, 'prayerTimes'))),
                body: SafeArea(
                    child: Center(
                        child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 640),
                            child: ListView(
                              padding: const EdgeInsets.all(16),
                              children: [
                                _dateHeader(context, scheme, shamsi, qamari),
                                const SizedBox(height: 20),
                                FutureBuilder<PrayerTimes>(
                                  future: _times,
                                  builder: (context, snapshot) {
                                    if (snapshot.hasError) {
                                      return Card(
                                          child: Padding(
                                        padding: const EdgeInsets.all(24),
                                        child: Column(children: [
                                          Icon(Icons.event_busy_outlined,
                                              size: 36, color: scheme.error),
                                          const SizedBox(height: 12),
                                          Text(
                                              LocalizationHelper.getText(
                                                  ref, 'prayerTimesLoadError'),
                                              textAlign: TextAlign.center),
                                          const SizedBox(height: 16),
                                          FilledButton.icon(
                                              onPressed: () =>
                                                  _setDate(_selectedDate),
                                              icon: const Icon(Icons.refresh),
                                              label: Text(
                                                  LocalizationHelper.getText(
                                                      ref, 'retry'))),
                                        ]),
                                      ));
                                    }
                                    if (snapshot.connectionState !=
                                            ConnectionState.done ||
                                        !snapshot.hasData) {
                                      return const Center(
                                          child: Padding(
                                              padding: EdgeInsets.all(36),
                                              child:
                                                  CircularProgressIndicator()));
                                    }
                                    final times = snapshot.data!;
                                    return Column(children: [
                                      if (_isSelectedKabulToday())
                                        _currentPrayerCard(times, scheme),
                                      if (!times.isOfficialTableEntry)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 12),
                                          child: Text(
                                              LocalizationHelper.getText(
                                                  ref, 'estimatedKabulTimes'),
                                              textAlign: TextAlign.center),
                                        ),
                                      _timeCard(
                                          LocalizationHelper.getText(
                                              ref, 'fajr'),
                                          times.fajr,
                                          Icons.nights_stay),
                                      _timeCard(
                                          LocalizationHelper.getText(
                                              ref, 'sunrise'),
                                          times.sunrise,
                                          Icons.wb_sunny_outlined),
                                      _timeCard(
                                          LocalizationHelper.getText(
                                              ref, 'dhuhr'),
                                          times.dhuhr,
                                          Icons.wb_sunny),
                                      _timeCard(
                                          LocalizationHelper.getText(
                                              ref, 'asr'),
                                          times.asr,
                                          Icons.wb_cloudy_outlined),
                                      _timeCard(
                                          LocalizationHelper.getText(
                                              ref, 'maghrib'),
                                          times.maghrib,
                                          Icons.wb_twilight),
                                      _timeCard(
                                          LocalizationHelper.getText(
                                              ref, 'isha'),
                                          times.isha,
                                          Icons.dark_mode_outlined),
                                    ]);
                                  },
                                ),
                              ],
                            )))),
              )),
    );
  }

  String _displayTime(String value) {
    final parts = value.split(':');
    final hour = int.parse(parts[0]);
    return '${hour % 12 == 0 ? 12 : hour % 12}:${parts[1]} ${hour < 12 ? 'AM' : 'PM'}';
  }

  Widget _dateHeader(BuildContext context, ColorScheme scheme,
      CalendarDate shamsi, CalendarDate qamari) {
    final text = Theme.of(context).textTheme;
    final gregorian =
        '${_selectedDate.year}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.day.toString().padLeft(2, '0')}';
    Widget dateDetail(String label, String value) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style:
                    text.labelMedium?.copyWith(color: scheme.onSurfaceVariant)),
            const SizedBox(height: 5),
            Text(value,
                textDirection: TextDirection.ltr,
                style: text.titleSmall?.copyWith(
                    color: scheme.onSurface, fontWeight: FontWeight.w600)),
          ],
        );
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            scheme.primaryContainer.withValues(alpha: 0.55),
            scheme.surfaceContainerLow
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(16)),
            child: Icon(Icons.calendar_month_rounded,
                color: scheme.onPrimaryContainer, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(LocalizationHelper.getText(ref, 'shamsi'),
                    style: text.labelLarge
                        ?.copyWith(color: scheme.onSurfaceVariant)),
                const SizedBox(height: 4),
                Text('$shamsi',
                    textDirection: TextDirection.ltr,
                    style: text.headlineSmall?.copyWith(
                        color: scheme.onSurface, fontWeight: FontWeight.w800)),
              ])),
        ]),
        const SizedBox(height: 22),
        Wrap(spacing: 32, runSpacing: 14, children: [
          dateDetail(LocalizationHelper.getText(ref, 'gregorian'), gregorian),
          dateDetail(LocalizationHelper.getText(ref, 'qamari'), '$qamari'),
        ]),
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Divider(height: 1, color: scheme.outlineVariant)),
        Wrap(spacing: 10, runSpacing: 10, children: [
          FilledButton.icon(
            style: FilledButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
            onPressed: _enterShamsiDate,
            icon: const Icon(Icons.edit_calendar_outlined, size: 18),
            label: Text(LocalizationHelper.getText(ref, 'shamsiDate')),
          ),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                side: BorderSide(color: scheme.outline),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
            onPressed: _pickGregorianDate,
            icon: const Icon(Icons.calendar_today_outlined, size: 18),
            label: Text(LocalizationHelper.getText(ref, 'gregorianDate')),
          ),
        ]),
      ]),
    );
  }

  Widget _timeCard(String name, String time, IconData icon) => Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(14)),
            child: Icon(icon,
                color: Theme.of(context).colorScheme.onSecondaryContainer),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          title: Text(name),
          trailing: Text(_displayTime(time),
              textDirection: TextDirection.ltr,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        ),
      );

  Widget _currentPrayerCard(PrayerTimes times, ColorScheme scheme) {
    final status = _prayerStatus(times);
    return Card(
      margin: const EdgeInsets.only(bottom: 18),
      color: scheme.primaryContainer,
      child: ListTile(
        contentPadding: const EdgeInsets.all(20),
        textColor: scheme.onPrimaryContainer,
        iconColor: scheme.onPrimaryContainer,
        leading: const Icon(Icons.access_time_filled),
        title: Text(
          '${LocalizationHelper.getText(ref, status.isNext ? 'nextPrayer' : 'currentPrayer')}: ${status.name}',
        ),
        subtitle: Text(
            '${LocalizationHelper.getText(ref, 'kabulTime')}: ${_formatTime(_kabulNow())}'),
        trailing: Text(_displayTime(status.time),
            textDirection: TextDirection.ltr,
            style: TextStyle(
                color: scheme.onPrimaryContainer,
                fontSize: 22,
                fontWeight: FontWeight.w700)),
      ),
    );
  }

  bool _isSelectedKabulToday() {
    final now = _kabulNow();
    return _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
  }

  DateTime _kabulNow() =>
      DateTime.now().toUtc().add(const Duration(hours: 4, minutes: 30));

  String _formatTime(DateTime date) => _displayTime(
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}');

  _PrayerStatus _prayerStatus(PrayerTimes times) {
    final prayers = [
      _PrayerStatus(LocalizationHelper.getText(ref, 'fajr'), times.fajr),
      _PrayerStatus(LocalizationHelper.getText(ref, 'dhuhr'), times.dhuhr),
      _PrayerStatus(LocalizationHelper.getText(ref, 'asr'), times.asr),
      _PrayerStatus(LocalizationHelper.getText(ref, 'maghrib'), times.maghrib),
      _PrayerStatus(LocalizationHelper.getText(ref, 'isha'), times.isha),
    ];
    final now = _kabulNow().hour * 60 + _kabulNow().minute;
    final currentIndex = prayers.lastIndexWhere(
      (prayer) => _minutes(prayer.time) <= now,
    );
    if (currentIndex == -1) {
      return _PrayerStatus(prayers.first.name, prayers.first.time,
          isNext: true);
    }
    return prayers[currentIndex];
  }

  int _minutes(String value) {
    final parts = value.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }
}

class _PrayerStatus {
  const _PrayerStatus(this.name, this.time, {this.isNext = false});

  final String name;
  final String time;
  final bool isNext;
}
