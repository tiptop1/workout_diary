import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:intl/intl.dart';
import 'package:workout_diary/src/gui/data_time_select_button.dart';
import 'package:workout_diary/src/gui/datetime_picker_widget.dart';
import 'package:workout_diary/src/model/exercise_set.dart';

import '../controller/redux_actions.dart';
import '../model/app_state.dart';
import '../model/exercise.dart';
import '../model/workout.dart';

const String dateLackMarker = '-';

typedef AddExerciseSetCallback = void Function();
typedef RemoveExerciseSetCallback = void Function(int index);
typedef ModifyExerciseSetCallback = void Function(
    int index, int exerciseId, String details);
typedef ExerciseSetRecord = (
  Exercise exercise,
  TextEditingController controller
);

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

  late List<ExerciseSetRecord> _exerciseSetRecords;

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
    _exerciseSetRecords =
        _createExerciseSetRecords(widget._workout?.exerciseSets ?? []);
    _formKey = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    _commentController.dispose();
    for (var r in _exerciseSetRecords) {
      r.$2.dispose();
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
                  onPressed: () => _saveWorkout(context),
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
                Expanded(
                  child: ExerciseSetsWidget(
                    setRecords: _exerciseSetRecords,
                    exercises: exercises,
                    addSetCallback: () => _addExerciseSetRecord(exercises[0]),
                    modifySetCallback: (i, exerciseId, details) =>
                        _modifyExerciseSetRecord(
                            i,
                            exercises.firstWhere((e) => e.id == exerciseId),
                            details),
                    removeSetCallback: (i) => _removeExerciseSetRecord(i),
                    modifiable: widget._modifiable,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _addExerciseSetRecord(Exercise initialExercise) {
    setState(() {
      _exerciseSetRecords.add((initialExercise, TextEditingController()));
    });
  }

  void _removeExerciseSetRecord(int index) {
    setState(() {
      var controller = _exerciseSetRecords[index].$2;
      _exerciseSetRecords.removeAt(index);
      controller.dispose();
    });
  }

  void _modifyExerciseSetRecord(int index, Exercise exercise, String details) {
    setState(() {
      var setRecord = _exerciseSetRecords[index];
      var controller = setRecord.$2;
      controller.text = details;
      _exerciseSetRecords[index] = (exercise, controller);
    });
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

  void _saveWorkout(BuildContext context) {
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

  List<ExerciseSet> _createExerciseSetsList() {
    return List.generate(_exerciseSetRecords.length, (index) {
      var exercise = _exerciseSetRecords[index].$1;
      var details = _exerciseSetRecords[index].$2.text;
      return ExerciseSet(
        exercise: exercise,
        details: details,
      );
    });
  }

  List<(Exercise, TextEditingController)> _createExerciseSetRecords(
      List<ExerciseSet> exerciseSets) {
    var records = <(Exercise, TextEditingController)>[];
    for (var es in exerciseSets) {
      records.add((es.exercise, TextEditingController(text: es.details ?? '')));
    }
    return records;
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
    showDialog(
        context: context,
        builder: (context) => const DateTimePickerWidget()).then((dateTime) {
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

class ExerciseSetsWidget extends StatelessWidget {
  final List<(Exercise, TextEditingController)> _setRecords;
  final List<Exercise> _exercises;
  final AddExerciseSetCallback _addSetCallback;
  final ModifyExerciseSetCallback _modifySetCallback;
  final RemoveExerciseSetCallback _removeSetCallback;
  final bool _modifiable;

  const ExerciseSetsWidget(
      {super.key,
      required List<(Exercise, TextEditingController)> setRecords,
      required List<Exercise> exercises,
      required AddExerciseSetCallback addSetCallback,
      required ModifyExerciseSetCallback modifySetCallback,
      required RemoveExerciseSetCallback removeSetCallback,
      bool modifiable = false})
      : _setRecords = setRecords,
        _exercises = exercises,
        _addSetCallback = addSetCallback,
        _modifySetCallback = modifySetCallback,
        _removeSetCallback = removeSetCallback,
        _modifiable = modifiable;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ...List.generate(
            _setRecords.length, (i) => _exerciseSetTile(i, _setRecords[i])),
        if (_modifiable)
          IconButton(onPressed: _addSetCallback, icon: const Icon(Icons.add)),
      ],
    );
  }

  Widget _exerciseSetTile(int i, (Exercise, TextEditingController) setRecord) {
    return ListTile(
      leading: _modifiable
          ? _exercisesDropDownButton(i, setRecord)
          : Text(setRecord.$1.name),
      title: _modifiable
          ? TextFormField(controller: setRecord.$2)
          : Text(setRecord.$2.value.text),
      trailing: _modifiable
          ? IconButton(
              onPressed: () => _removeSetCallback(i),
              icon: const Icon(Icons.delete),
            )
          : null,
    );
  }

  Widget _exercisesDropDownButton(
      int i, (Exercise, TextEditingController) setRecord) {
    return DropdownButton<int>(
      items: List.generate(
          _exercises.length, (i) => exerciseDropdownMenuItem(_exercises[i])),
      value: setRecord.$1.id,
      onChanged: (int? exerciseId) =>
          _modifySetCallback(i, exerciseId!, setRecord.$2.value.text),
    );
  }

  DropdownMenuItem<int> exerciseDropdownMenuItem(Exercise exercise) {
    return DropdownMenuItem<int>(
      value: exercise.id,
      child: Text(exercise.name),
    );
  }
}
