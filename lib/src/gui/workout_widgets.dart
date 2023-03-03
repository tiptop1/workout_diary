import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:intl/intl.dart';
import 'package:tuple/tuple.dart';
import 'package:workout_diary/src/gui/data_time_select_button.dart';
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
  final Workout? _workout;
  final bool _modifiable;

  const WorkoutWidget({Key? key, Workout? workout, bool modifiable = false})
      : _workout = workout,
        _modifiable = modifiable,
        super(key: key);

  @override
  State<WorkoutWidget> createState() => _AddWorkoutState();
}

class _AddWorkoutState extends State<WorkoutWidget> {
  static const int titleMaxLength = 500;
  DateTime? _startTime;
  DateTime? _endTime;
  late TextEditingController _titleController;
  late TextEditingController _commentController;
  late List<Tuple2<Exercise, TextEditingController>> _entryTuples;
  late final GlobalKey<FormState> _formKey;

  @override
  void initState() {
    super.initState();
    _startTime = widget._workout?.startTime;
    _endTime = widget._workout?.endTime;
    _titleController = TextEditingController();
    _titleController.text = widget._workout?.title ?? '';
    _commentController = TextEditingController();
    _commentController.text = widget._workout?.comment ?? '';
    _entryTuples = _createEntryTuples();
    _formKey = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    _commentController.dispose();
    for (var t in _entryTuples) {
      t.item2.dispose();
    }
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appLocalizations = AppLocalizations.of(context)!;
    return StoreConnector<AppState, List<Exercise>>(
      converter: (store) => store.state.exercises,
      builder: (context, exercises) {
        return Scaffold(
          appBar: AppBar(
            title: Text(appLocalizations.addWorkoutTitle),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => _backButtonCallback(context),
            ),
            actions: [
              if (widget._modifiable)
                IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () => _saveButtonCallback(context),
                ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: Column(
              children: [
                _createTitleTextField(context, appLocalizations),
                DateTimeSelectRow(
                  rowName: appLocalizations.start,
                  initialDateTime: _startTime,
                  updateCallback: (newStartTime) => _startTime = newStartTime,
                  modifiable: widget._modifiable,
                ),
                DateTimeSelectRow(
                  rowName: appLocalizations.end,
                  initialDateTime: _endTime,
                  updateCallback: (newEndTime) => _endTime = newEndTime,
                  modifiable: widget._modifiable,
                ),
                _createCommentTextField(context, appLocalizations),
                _createWorkoutEntryWidget(context, exercises),
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
  }

  Widget _createTitleTextField(
      BuildContext context, AppLocalizations appLocalizations) {
    FormFieldValidator<String>? validator;
    if (widget._modifiable) {
      validator = (String? value) {
        String? msg;
        if (value == null || value.isEmpty) {
          msg = appLocalizations.workoutTitleValidation_required;
        } else if (value.length > titleMaxLength) {
          msg = appLocalizations.workoutTitleValidation_tooLong(titleMaxLength);
        }
        return msg;
      };
    }
    return TextFormField(
      enabled: widget._modifiable,
      validator: validator,
      controller: _titleController,
      decoration: InputDecoration(
          labelText: appLocalizations.workoutTitle,
          border: const OutlineInputBorder(),
          hintText: appLocalizations.workoutTitleHint),
    );
  }

  void _backButtonCallback(BuildContext context) {
    Navigator.pop(context, null);
  }

  void _saveButtonCallback(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      Object action;
      var workout = Workout(
          id: widget._workout != null ? widget._workout!.id : null,
          startTime: _startTime,
          endTime: _endTime,
          title: _titleController.value.text,
          comment: _commentController.value.text,
          exerciseSets: _createExerciseSetsList());
      if (widget._workout == null) {
        action = AddWorkoutAction(
          workout: workout,
        );
      } else {
        action = ModifyWorkoutAction(
          workout: workout,
        );
      }
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

  Widget _createCommentTextField(
      BuildContext context, AppLocalizations appLocalizations) {
    return TextFormField(
      controller: _commentController,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
          labelText: appLocalizations.workoutComment,
          border: const OutlineInputBorder(),
          hintText: appLocalizations.workoutCommentHint),
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

  List<Tuple2<Exercise, TextEditingController>> _createEntryTuples() {
    var entryTuples = <Tuple2<Exercise, TextEditingController>>[];
    for (ExerciseSet exerciseSet
        in widget._workout?.exerciseSets ?? List.empty()) {
      var controller = TextEditingController(text: exerciseSet.details ?? '');
      entryTuples.add(Tuple2(exerciseSet.exercise, controller));
    }
    return entryTuples;
  }
}

class DateTimeSelectRow extends StatefulWidget {
  final DateTime? initialDateTime;
  final String rowName;
  final void Function(DateTime? dateTime) updateCallback;
  final bool modifiable;

  const DateTimeSelectRow(
      {Key? key,
      this.initialDateTime,
      required this.rowName,
      required this.updateCallback,
      this.modifiable = false})
      : super(key: key);

  @override
  State<DateTimeSelectRow> createState() => _DateTimeSelectRowState();
}

class _DateTimeSelectRowState extends State<DateTimeSelectRow> {
  DateTime? _dateTime;

  @override
  void initState() {
    super.initState();
    _dateTime = widget.initialDateTime;
  }

  @override
  Widget build(BuildContext context) {
    Widget? dateTimeWidget;
    if (_dateTime == null) {
      dateTimeWidget = widget.modifiable
          ? DateTimeSelectButton(
              selectDate: true,
              selectTime: true,
              onPressed: _setDateTimeCallback)
          : null;
    } else {
      dateTimeWidget = InputChip(
        label: Text(DateFormat.yMd().add_jm().format(_dateTime!)),
        onPressed: widget.modifiable ? _setDateTimeCallback : null,
        onDeleted: widget.modifiable ? _removeDateTimeCallback : null,
      );
    }
    return Row(
      children: [
        Text(widget.rowName),
        if (dateTimeWidget != null) dateTimeWidget,
      ],
    );
  }

  void _setDateTimeCallback() {
    showDialog(context: context, builder: (context) => const DateTimePickerWidget())
        .then((dateTime) {
      setState(() {
        _dateTime = dateTime;
      });
      widget.updateCallback(dateTime);
    });
  }

  void _removeDateTimeCallback() {
    setState(() {
      _dateTime = null;
    });
    widget.updateCallback(null);
  }
}
