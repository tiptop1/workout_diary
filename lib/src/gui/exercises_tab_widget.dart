import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:workout_diary/src/controller/redux_actions.dart';
import 'package:workout_diary/src/gui/list_widget.dart';
import 'package:workout_diary/src/model/workout.dart';

import '../model/app_state.dart';
import '../model/exercise.dart';
import 'exercise_widget.dart';

class ExercisesTabWidget extends ListWidget<Exercise> {
  const ExercisesTabWidget({Key? key}) : super(key: key);

  @override
  List<Exercise> storeConnectorConverter(Store<AppState> store) =>
      store.state.exercises;

  @override
  Widget listItemTitle(BuildContext context, Exercise exercise) =>
      Text(exercise.name);

  @override
  void listItemModifyAction(BuildContext context, Exercise exercise) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseWidget(
            key: UniqueKey(), exerciseId: exercise.id!, modifiable: true),
      ),
    );
  }

  @override
  void listItemDeleteAction(BuildContext context, Exercise exercise) {
    var exerciseId = exercise.id;
    assert(exerciseId != null, "Deleting exercise without id isn't allowed.");
    var relationsCount = countRelations(StoreProvider.of<AppState>(context).state.workouts, exerciseId!);
    _showDialogAndDeleteExercise(context, relationsCount, exerciseId);
  }

  void listItemShowAction(BuildContext context, Exercise exercise) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ExerciseWidget(key: UniqueKey(), exerciseId: exercise.id!),
      ),
    );
  }

  void _showDialogAndDeleteExercise(
      BuildContext context, int relationsCount, int exerciseId) {
    AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return AlertDialog(
            title: Text(appLocalizations.deleteExerciseTitle),
            content: _dialogContent(appLocalizations, relationsCount),
            actions: <Widget>[
              TextButton(
                child: Text(appLocalizations.yes),
                onPressed: () {
                  StoreProvider.of<AppState>(context).dispatch(DeleteExerciseAction(exerciseId: exerciseId));
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text(appLocalizations.no),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  Widget _dialogContent(AppLocalizations appLocalizations, int relationsCount) {
    var msg;
    var icon;
    var iconColor;
    if (relationsCount < 1) {
      msg = appLocalizations.deleteExerciseInfo;
      icon = Icons.info;
      iconColor = Colors.blue;
    } else if (relationsCount == 1) {
      msg = appLocalizations.deleteExerciseWarning1;
      icon = Icons.warning;
      iconColor = Colors.yellow;
    } else {
      msg = appLocalizations.deleteExerciseWarning2(relationsCount);
      icon = Icons.warning;
      iconColor = Colors.yellow;
    }

    return Row(children: [
      Expanded(
        flex: 20,
        child: FittedBox(
          fit: BoxFit.fill,
          child: Icon(icon, color: iconColor),
        ),
      ),
      Spacer(flex: 2),
      Expanded(
        flex: 60,
        child: Text(msg),
      ),
    ]);
  }

  int countRelations(List<Workout> workouts, int exerciseId) {
    var count = 0;
    for (var workout in workouts) {
      count += workout.exerciseSets.where((es) => es.exercise.id == exerciseId).length;
    }
    return count;
  }
}
