import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:intl/intl.dart';
import 'package:tuple/tuple.dart';
import 'package:workout_diary/src/gui/datetime_picker_widget.dart';
import 'package:workout_diary/src/model/exercise_set.dart';

import '../controller/redux_actions.dart';
import '../model/app_state.dart';
import '../model/exercise.dart';
import '../model/workout.dart';

const String dateLackMarker = '-';

String dateStr(Locale locale, DateTime dateTime) =>
    DateFormat.yMd(locale.toLanguageTag()).format(dateTime);

String dateTimeStr(Locale locale, DateTime dateTime) =>
    '${dateStr(locale, dateTime)} ${DateFormat.jm(locale.toLanguageTag()).format(dateTime)}';

class WorkoutWidget extends StatefulWidget {
  const WorkoutWidget({Key? key}) : super(key: key);

  @override
  State<WorkoutWidget> createState() => _AddWorkoutState();
}

class _AddWorkoutState extends State<WorkoutWidget> {
  static const int titleMaxLength = 500;
  DateTime? _startTime;
  DateTime? _endTime;
  late TextEditingController _titleController;
  late TextEditingController _preCommentController;
  late TextEditingController _postCommentController;
  late List<Tuple2<Exercise, TextEditingController>> _entryTuples;
  late final GlobalKey<FormState> _formKey;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _preCommentController = TextEditingController();
    _postCommentController = TextEditingController();
    _entryTuples = [];
    _formKey = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    _postCommentController.dispose();
    _preCommentController.dispose();
    _entryTuples.forEach((t) => t.item2.dispose());
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appLocalizations = AppLocalizations.of(context)!;
    Locale locale = Localizations.localeOf(context);
    var widget = StoreConnector<AppState, List<Exercise>>(
      converter: (store) => store.state.exercises,
      builder: (context, exercises) {
        return Scaffold(
          appBar: AppBar(
            title: Text(appLocalizations.addWorkoutTitle),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => _backButtonCallback(context),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.check),
                onPressed: () => _saveButtonCallback(context),
              ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: Column(
              children: [
                _createTitleWidget(context, appLocalizations),
                _createDateTimeRow(
                    context, locale, appLocalizations.start, null, _startTime,
                    (dateTime) {
                  setState(() {
                    _startTime = dateTime;
                    _endTime = null;
                  });
                }),
                _createDateTimeRow(
                    context, locale, appLocalizations.end, _startTime, _endTime,
                    (dateTime) {
                  setState(() {
                    _endTime = dateTime;
                  });
                }),
                _createPrecommentWidget(context, appLocalizations),
                _createWorkoutEntryWidget(context, exercises),
                _createPostcommentWidget(context, appLocalizations),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
              onPressed: () {
                setState(() {
                  _entryTuples
                      .add(Tuple2(exercises.first, TextEditingController()));
                });
              },
              child: const Icon(Icons.add)),
        );
      },
    );

    return widget;
  }

  Widget _createTitleWidget(
      BuildContext context, AppLocalizations appLocalizations) {
    return TextFormField(
      validator: (value) {
        var msg;
        if (value == null || value.isEmpty) {
          msg = appLocalizations.workoutTitleValidation_required;
        } else if (value.length > titleMaxLength) {
          msg = appLocalizations.workoutTitleValidation_tooLong(titleMaxLength);
        }
        return msg;
      },
      controller: _titleController,
      decoration: InputDecoration(
          labelText: appLocalizations.workoutTitle,
          border: OutlineInputBorder(),
          hintText: appLocalizations.workoutTitleHint),
    );
  }

  void _backButtonCallback(BuildContext context) {
    Navigator.pop(context, null);
  }

  void _saveButtonCallback(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      var action = AddWorkoutAction(
        workout: Workout(
            startTime: _startTime,
            endTime: _endTime,
            title: _titleController.value.text,
            preComment: _preCommentController.value.text,
            postComment: _postCommentController.value.text,
            exerciseSets: _createExerciseSetsList()),
      );
      Navigator.pop(context, action);
    }
  }

  Widget _createWorkoutEntryWidget(
      BuildContext context, List<Exercise> exercises) {
    var listTiles = <Widget>[];
    for (var i = 0; i < _entryTuples.length; i++) {
      listTiles.add(_createWorkoutEntryListTile(i, exercises, _entryTuples[i]));
    }
    return Expanded(
      child: ListView(
        children: listTiles,
      ),
    );
  }

  Widget _createPrecommentWidget(
      BuildContext context, AppLocalizations appLocalizations) {
    return TextFormField(
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
    return TextFormField(
      controller: _postCommentController,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
          labelText: appLocalizations.workoutPostcomment,
          border: OutlineInputBorder(),
          hintText: appLocalizations.workoutPostcommentHint),
    );
  }

  Widget _createWorkoutEntryListTile(int index, List<Exercise> exercises,
      Tuple2<Exercise, TextEditingController> workoutEntryTuple) {
    return ListTile(
      leading:
          _createExerciseDropDownButton(index, exercises, workoutEntryTuple),
      title: TextFormField(controller: workoutEntryTuple.item2),
    );
  }

  Widget _createExerciseDropDownButton(int index, List<Exercise> exercises,
      Tuple2<Exercise, TextEditingController> workoutEntryTuple) {
    return DropdownButton<int>(
        items:
            exercises.map((e) => _createExerciseDropdownMenuItem(e)).toList(),
        value: workoutEntryTuple.item1.id,
        onChanged: (int? newExerciseId) {
          setState(() {
            _entryTuples[index] = workoutEntryTuple.withItem1(exercises
                .firstWhere((exercise) => exercise.id == newExerciseId));
          });
        });
  }

  DropdownMenuItem<int> _createExerciseDropdownMenuItem(Exercise exercise) {
    return DropdownMenuItem<int>(
      value: exercise.id,
      child: Text(exercise.name),
    );
  }

  Widget _createDateTimeRow(
      BuildContext context,
      Locale locale,
      String fieldName,
      DateTime? minTime,
      DateTime? initTime,
      Function dateTimePickerCallback) {
    return Row(
      children: [
        Text(
            '$fieldName: ${initTime != null ? dateTimeStr(locale, initTime) : ""}'),
        IconButton(
            onPressed: () {
              showDialog(
                      context: context, builder: (_) => DateTimePickerWidget())
                  .then((dateTime) => dateTimePickerCallback(dateTime));
            },
            icon: Icon(Icons.access_time)),
      ],
    );
  }

  List<ExerciseSet> _createExerciseSetsList() {
    return List.generate(_entryTuples.length, (index) {
      var exercise = _entryTuples[index].item1;
      var details = _entryTuples[index].item2.text;
      return ExerciseSet(
        exercise: exercise,
        details: details,
      );
    });
  }
}
