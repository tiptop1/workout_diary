import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'removable_button_widget.dart';

class DateTimePickerWidget extends StatefulWidget {
  const DateTimePickerWidget({Key? key}) : super(key: key);

  @override
  State<DateTimePickerWidget> createState() => _DateTimePickerWidgetState();
}

class _DateTimePickerWidgetState extends State<DateTimePickerWidget> {
  static const int dateTimeOffset = 6;
  late bool _timeIsSet;
  late DateTime _dateTime;

  @override
  void initState() {
    super.initState();
    var now = DateTime.now();
    _dateTime = DateTime(now.year, now.month, now.day);
    _timeIsSet = false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CalendarDatePicker(
          initialDate: _dateTime,
          firstDate: DateTime(
              _dateTime.year, _dateTime.month - dateTimeOffset, _dateTime.day),
          lastDate: DateTime(
              _dateTime.year, _dateTime.month + dateTimeOffset, _dateTime.day),
          onDateChanged: (newDate) {
            setState(() {
              _dateTime = DateTime(newDate.year, newDate.month, newDate.day);
            });
          },
        ),
        _buildTimeSelectRow(context),
        _buildActionsRow(context),
      ],
    );
  }

  Widget _buildTimeSelectRow(BuildContext context) {
    return !_timeIsSet
        ? IconButton(
            icon: Icon(Icons.access_time),
            onPressed: () => _showTimePicker(context),
          )
        : RemovableButton(
            child: Text(TimeOfDay.fromDateTime(_dateTime).format(context)),
            onPressed: () => _showTimePicker(context),
            onRemoved: () {
              setState(() {
                _dateTime = DateTime(
                    _dateTime.year, _dateTime.month, _dateTime.day, 0, 0, 0);
                _timeIsSet = false;
              });
            });
  }

  Widget _buildActionsRow(BuildContext context) {
    var loc = AppLocalizations.of(context)!;
    return Row(
      children: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(loc.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_dateTime),
          child: Text(loc.ok),
        ),
      ],
    );
  }

  void _showTimePicker(BuildContext context) {
    showTimePicker(
            context: context,
            initialTime: _timeIsSet
                ? TimeOfDay.fromDateTime(_dateTime)
                : TimeOfDay.now())
        .then((time) {
      setState(() {
        if (time != null) {
          _dateTime = DateTime(_dateTime.year, _dateTime.month, _dateTime.day,
              time.hour, time.minute);
          _timeIsSet = true;
        }
      });
    });
  }
}
