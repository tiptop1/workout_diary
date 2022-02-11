import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../domain.dart';
import '../gui/progress_widget.dart';

class AddWorkoutWidget extends StatefulWidget {
  @override
  State<AddWorkoutWidget> createState() => _AddWorkoutState();
}

class _AddWorkoutState extends State<AddWorkoutWidget> {
  static const String dateLackMarker = '-';

  List<Workout>? _workouts;

  late TextEditingController _preCommentController;
  late TextEditingController _postCommentController;
  late List<TextEditingController> _entryControllers;

  @override
  void initState() {
    super.initState();
    _preCommentController = TextEditingController();
    _postCommentController = TextEditingController();
    _entryControllers = [];
  }

  @override
  void dispose() {
    _postCommentController.dispose();
    _preCommentController.dispose();
    _entryControllers.forEach((c) => c.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var widget;
    if (_workouts == null) {
      widget = createAddWorkoutWidget(context);
    } else {
      widget = ProgressWidget();
    }
    return widget;
  }

  Widget createAddWorkoutWidget(BuildContext context) {
    var appLocalizations = AppLocalizations.of(context)!;

    return Scaffold(
        appBar: AppBar(
          title: Text(appLocalizations.addWorkoutTitle),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                _backButtonCallback(context);
              }),
        ),
        body: Column(
          children: [
            _createTimeBar(context, appLocalizations, null, null),
            _createPrecommentWidget(context, appLocalizations),
            _createWorkoutEntries(context),
            _createPostcommentWidget(context, appLocalizations),
          ],
        ));
  }

  Widget _createTimeBar(BuildContext context, AppLocalizations appLocalizations,
      DateTime? start, DateTime? end) {
    var locale = Localizations.localeOf(context);
    var startStr = start != null ? _dateTimeStr(locale, start) : dateLackMarker;
    var endStr = end != null ? _dateTimeStr(locale, end) : dateLackMarker;

    return Row(
      children: [
        Text(
            '${appLocalizations.start}: $startStr, ${appLocalizations.end}: $endStr'),
        // TODO: Add buttons to control time
      ],
    );
  }

  String _dateTimeStr(Locale locale, DateTime dateTime) =>
      '${DateFormat.yMMMMd(locale).format(dateTime)} ${DateFormat.jm(locale).format(dateTime)}';

  void _backButtonCallback(BuildContext context) =>
      throw UnsupportedError('Not implemented yet!');

  Widget _createWorkoutEntries(BuildContext context) =>
      throw UnsupportedError('Not implemented yet!');

  Widget _createPrecommentWidget(
      BuildContext context, AppLocalizations appLocalizations) {
    return TextField(
      controller: _preCommentController,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
          labelText: appLocalizations.workoutPrecomment,
          border: OutlineInputBorder(),
          hintText: appLocalizations.workoutPrecommentHint),
    );
  }

  Widget _createPostcommentWidget(
      BuildContext context, AppLocalizations appLocalizations) {
    return TextField(
      controller: _postCommentController,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
          labelText: appLocalizations.workoutPostcomment,
          border: OutlineInputBorder(),
          hintText: appLocalizations.workoutPostcommentHint),
    );
  }
}
