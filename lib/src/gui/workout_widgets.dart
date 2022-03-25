import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:tuple/tuple.dart';
import 'package:workout_diary/src/domain.dart';
import 'package:workout_diary/src/gui/progress_widget.dart';
import 'package:workout_diary/src/repository.dart';

const String dateLackMarker = '-';

String dateTimeStr(Locale locale, DateTime dateTime) =>
    '${DateFormat.yMMMMd(locale).format(dateTime)} ${DateFormat.jm(locale).format(dateTime)}';

class AddWorkoutWidget extends StatefulWidget {
  @override
  State<AddWorkoutWidget> createState() => _AddWorkoutState();
}

// TODO: Ensure that at least one Exercise has been added to database.
class _AddWorkoutState extends State<AddWorkoutWidget> {

  bool _inProgress = false;
  DateTime? _startTime;
  DateTime? _endTime;
  late TextEditingController _titleController;
  late TextEditingController _preCommentController;
  late TextEditingController _postCommentController;
  late List<Tuple2<Exercise, TextEditingController>> _entryTuples;
  late List<Exercise>? _exercises;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _preCommentController = TextEditingController();
    _postCommentController = TextEditingController();
    _entryTuples = [];
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
    var widget;
    if (_exercises == null) {
      _inProgress = true;
      Repository.of(context).findAllExerciseSummaries().then((exercises) {
        setState(() {
          _exercises = exercises;
          _inProgress = false;
        });
      });
    }
    if (_inProgress) {
      widget = ProgressWidget();
    } else {
      widget = Scaffold(
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
            _createTitleWidget(context, appLocalizations),
            _createTimeBar(context, appLocalizations, _startTime, _endTime),
            _createPrecommentWidget(context, appLocalizations),
            _createWorkoutEntryWidget(context),
            _createPostcommentWidget(context, appLocalizations),
          ],
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              setState(() {
                _entryTuples
                    .add(Tuple2(_exercises!.first, TextEditingController()));
              });
            },
            child: const Icon(Icons.add)),
      );
    }
    return widget;
  }

  Widget _createTitleWidget(
      BuildContext context, AppLocalizations appLocalizations) {
    return TextField(
      controller: _titleController,
      decoration: InputDecoration(
          labelText: appLocalizations.workoutTitle,
          border: OutlineInputBorder(),
          hintText: appLocalizations.workoutTitleHint),
    );
  }

  Widget _createTimeBar(BuildContext context, AppLocalizations appLocalizations,
      DateTime? start, DateTime? end) {
    var locale = Localizations.localeOf(context);
    var startStr = start != null ? dateTimeStr(locale, start) : dateLackMarker;
    var endStr = end != null ? dateTimeStr(locale, end) : dateLackMarker;

    return Row(
      children: [
        Text(
            '${appLocalizations.start}: $startStr, ${appLocalizations.end}: $endStr'),
        _createTimeControlButton(
          icon: Icons.play_arrow,
          isEnabled:
              (start != null && end != null) || (start == null && end == null),
          onPress: () {
            _startTime = DateTime.now();
            _endTime = null;
          },
        ),
        _createTimeControlButton(
          icon: Icons.stop,
          isEnabled: start != null,
          onPress: () => _endTime = DateTime.now(),
        ),
      ],
    );
  }



  void _backButtonCallback(BuildContext context) {
    var workout = Workout(
        startTime: _startTime,
        endTime: _endTime,
        title: _titleController.value.text,
        preComment: _preCommentController.value.text,
        postComment: _postCommentController.value.text);
    var repo = Repository.of(context);
    repo.insertWorkout(workout).then((insertedWorkout) {
      repo
          .insertAllWorkoutEntries(
              _createWorkoutEntriesList(insertedWorkout, _entryTuples))
          .then((insertedEntriesList) {
        Navigator.pop(context, true);
      });
      // TODO: Add error handling for workout entries insert.
    });
    // TODO: Add error handling for workout insert.
    setState(() => _inProgress = true);
  }

  Widget _createWorkoutEntryWidget(BuildContext context) {
    var listTiles = <Widget>[];
    for (var i = 0; i < _entryTuples.length; i++) {
      listTiles.add(_createWorkoutEntryListTile(i, _entryTuples[i]));
    }
    return ListView(
      children: listTiles,
    );
  }

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

  Widget _createTimeControlButton(
      {required IconData icon,
      required bool isEnabled,
      required VoidCallback onPress}) {
    return ElevatedButton(
        onPressed: isEnabled ? onPress : null, child: Icon(icon));
  }

  List<WorkoutEntry> _createWorkoutEntriesList(Workout workout,
      List<Tuple2<Exercise, TextEditingController>> entryTuples) {
    var entries = <WorkoutEntry>[];
    _entryTuples.forEach((t) => entries.add(WorkoutEntry(
          exercise: t.item1,
          workout: workout,
          details: t.item2.value.text,
        )));
    return entries;
  }

  Widget _createWorkoutEntryListTile(
      int index, Tuple2<Exercise, TextEditingController> workoutEntryTuple) {
    return ListTile(
      leading: _createDropDownButton(index, workoutEntryTuple),
      title: TextField(controller: workoutEntryTuple.item2),
    );
  }

  Widget _createDropDownButton(
      int index, Tuple2<Exercise, TextEditingController> workoutEntryTuple) {
    return DropdownButton<int>(
        items: _exercises!.map((e) => _createDropdownMenuItem(e)).toList(),
        value: workoutEntryTuple.item1.id,
        onChanged: (int? newExerciseId) {
          setState(() {
            _entryTuples[index] = workoutEntryTuple.withItem1(_exercises!
                .firstWhere((exercise) => exercise.id == newExerciseId));
          });
        });
  }

  DropdownMenuItem<int> _createDropdownMenuItem(Exercise exercise) {
    return DropdownMenuItem<int>(
      value: exercise.id,
      child: Text(exercise.name),
    );
  }
}
