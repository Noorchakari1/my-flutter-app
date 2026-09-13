import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/calendar_converter.dart';
import '../../../../core/utils/localization_helper.dart';

enum _CalendarKind { gregorian, shamsi, qamari }

class DateConverterScreen extends ConsumerStatefulWidget {
  const DateConverterScreen({super.key});

  @override
  ConsumerState<DateConverterScreen> createState() => _DateConverterScreenState();
}

class _DateConverterScreenState extends ConsumerState<DateConverterScreen> {
  _CalendarKind _kind = _CalendarKind.gregorian;
  final _controller = TextEditingController();
  DateTime? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller.text = _formatGregorian(DateTime.now());
    _convert();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _convert() {
    try {
      final values = _controller.text.trim().split('/').map(int.parse).toList();
      if (values.length != 3) throw const FormatException();
      final input = CalendarDate(values[0], values[1], values[2]);
      final date = switch (_kind) {
        _CalendarKind.gregorian => DateTime(input.year, input.month, input.day),
        _CalendarKind.shamsi => CalendarConverter.solarHijriToGregorian(input),
        _CalendarKind.qamari => CalendarConverter.qamariToGregorian(input),
      };
      if (_kind == _CalendarKind.gregorian &&
          (date.year != input.year ||
              date.month != input.month ||
              date.day != input.day)) {
        throw const FormatException();
      }
      if (!CalendarConverter.isSupportedGregorian(date)) {
        throw const FormatException();
      }
      setState(() { _result = date; _error = null; });
    } catch (_) {
      setState(() {
        _result = null;
        _error = LocalizationHelper.getText(ref, 'validDateError');
      });
    }
  }

  String _formatGregorian(DateTime date) => '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final date = _result;
    return Scaffold(
      appBar: AppBar(title: Text(LocalizationHelper.getText(ref, 'dateConverter'))),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Text(LocalizationHelper.getText(ref, 'dateConverterDescription')),
        const SizedBox(height: 20),
        SegmentedButton<_CalendarKind>(
          segments: [
            ButtonSegment(value: _CalendarKind.gregorian, label: Text(LocalizationHelper.getText(ref, 'miladi'))),
            ButtonSegment(value: _CalendarKind.shamsi, label: Text(LocalizationHelper.getText(ref, 'shamsi'))),
            ButtonSegment(value: _CalendarKind.qamari, label: Text(LocalizationHelper.getText(ref, 'qamari'))),
          ],
          selected: {_kind},
          onSelectionChanged: (value) {
            setState(() => _kind = value.first);
            _convert();
          },
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _controller,
          keyboardType: TextInputType.datetime,
          decoration: InputDecoration(labelText: LocalizationHelper.getText(ref, 'date'), hintText: 'YYYY/MM/DD', errorText: _error),
          onSubmitted: (_) => _convert(),
        ),
        const SizedBox(height: 12),
        FilledButton(onPressed: _convert, child: Text(LocalizationHelper.getText(ref, 'convert'))),
        if (date != null) ...[
          const SizedBox(height: 24),
          _resultCard(LocalizationHelper.getText(ref, 'miladi'), _formatGregorian(date)),
          _resultCard(LocalizationHelper.getText(ref, 'shamsi'), CalendarConverter.toSolarHijri(date).toString()),
          _resultCard(LocalizationHelper.getText(ref, 'qamari'), CalendarConverter.toQamari(date).toString()),
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(LocalizationHelper.getText(ref, 'qamariConversionNote'), style: const TextStyle(fontSize: 12)),
          ),
        ],
      ]),
    );
  }

  Widget _resultCard(String label, String value) => Card(
        child: ListTile(title: Text(label), trailing: Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
      );
}
