import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:intl/intl.dart';
import 'package:workout_diary/src/presentation/bloc/workout_diary_events.dart';

import '../../domain/entity/exercise.dart';
import '../../domain/entity/exercise_set.dart';
import '../../domain/entity/workout.dart';
import '../widgets/data_time_select_button.dart';
import '../widgets/datetime_picker_widget.dart';

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

class WorkoutRoute extends StatefulWidget {
  final Workout? workout;
  final List<Exercise> exercises;
  final bool modifiable;
  
  const WorkoutRoute({super.key, this.workout, required this.exercises, this.modifiable = false});

  @override
  State<WorkoutRoute> createState() => workoutRouteState();
}

class workoutRouteState extends State<WorkoutRoute> {
  static const int titleMaxLength = 500;
  late DateTime _startTime;
  DateTime? _endTime;
  late TextEditingController _titleController;
  late TextEditingController _commentController;

  late List<ExerciseSetRecord> _exerciseSetRecords;

  late final GlobalKey<FormState> _formKey;

  @override
  void initState() {
    super.initState();
    _startTime = widget.workout?.startTime;
    _endTime = widget.workout?.endTime;
    _titleController = TextEditingController();
    _titleController.text = widget.workout?.title ?? '';
    _commentController = TextEditingController();
    _commentController.text = widget.workout?.comment ?? '';
    _exerciseSetRecords =
        _createExerciseSetRecords(widget.workout?.exerciseSets ?? []);
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
        return Scaffold(
          appBar: AppBar(
            title: Text(appLocalizations.addWorkoutTitle),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => _backButtonCallback(context),
            ),
            actions: [
              if (widget.modifiable)
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
                  modifiable: widget.modifiable,
                ),
                DateTimeSelectRow(
                  rowName: appLocalizations.end,
                  initialDateTime: _endTime,
                  updateCallback: (newEndTime) => _endTime = newEndTime,
                  modifiable: widget.modifiable,
                ),
                _createCommentTextField(context, appLocalizations),
                Expanded(
                  child: ExerciseSetsWidget(
                    setRecords: _exerciseSetRecords,
                    exercises: widget.exercises,
                    addSetCallback: () => _addExerciseSetRecord(widget.exercises[0]),
                    modifySetCallback: (i, exerciseId, details) =>
                        _modifyExerciseSetRecord(
                            i,
                            widget.exercises.firstWhere((e) => e.id == exerciseId),
                            details),
                    removeSetCallback: (i) => _removeExerciseSetRecord(i),
                    modifiable: widget.modifiable,
                  ),
                ),
              ],
            ),
          ),
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
    if (widget.modifiable) {
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
      enabled: widget.modifiable,
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
      WorkoutDiaryEvent event;
      if (widget.workout == null) {
        event = AddWorkoutEvent(title: _titleController.value.text, startTime: _startTime, endTime: _endTime, comment: _commentController.value.text, exerciseSets: _createExerciseSetsList());
      } else {
        var modifiedWorkout = Workout(id: widget.workout!.id, title: _titleController.value.text, startTime: _startTime, endTime: _endTime, comment: _commentController.value.text, exerciseSets: _createExerciseSetsList());
        event = ModifyWorkoutEvent(workout: modifiedWorkout);
      }
      Navigator.pop(context, event);
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
  final bool modifiable;

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
        modifiable = modifiable;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ...List.generate(
            _setRecords.length, (i) => _exerciseSetTile(i, _setRecords[i])),
        if (modifiable)
          IconButton(onPressed: _addSetCallback, icon: const Icon(Icons.add)),
      ],
    );
  }

  Widget _exerciseSetTile(int i, (Exercise, TextEditingController) setRecord) {
    return ListTile(
      leading: modifiable
          ? _exercisesDropDownButton(i, setRecord)
          : Text(setRecord.$1.name),
      title: modifiable
          ? TextFormField(controller: setRecord.$2)
          : Text(setRecord.$2.value.text),
      trailing: modifiable
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
      value: setRecord.$1.id.id,
      onChanged: (int? exerciseId) =>
          _modifySetCallback(i, exerciseId!, setRecord.$2.value.text),
    );
  }

  DropdownMenuItem<int> exerciseDropdownMenuItem(Exercise exercise) {
    return DropdownMenuItem<int>(
      value: exercise.id.id,
      child: Text(exercise.name),
    );
  }
}
