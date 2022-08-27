import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:workout_diary/src/gui/list_tab_widget.dart';

import '../model/exercise.dart';
import '../model/repository.dart';
import 'exercise_widgets.dart';

enum ExerciseAction { modify, delete }

class AllExercisesTabWidget extends ListOnTabWidget {
  const AllExercisesTabWidget({Key? key}) : super(key: key);

  @override
  State<AllExercisesTabWidget> createState() => _AllExercisesState();
}

class _AllExercisesState
    extends ListOnTabState<AllExercisesTabWidget, Exercise> {
  @override
  void loadEntities(BuildContext context) {
    GetIt.I.get<Repository>()
        .findAllExerciseSummaries()
        .then((List<Exercise> exercises) {
      setState(() {
        entities = exercises;
        entitiesReady = true;
      });
    });
  }

  Widget listItemTitle(BuildContext context, Exercise exercise) =>
      Text(exercise.name);

  void listItemModifyAction(BuildContext context, Exercise exercise) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseWidget(
            key: UniqueKey(), exerciseId: exercise.id!, modifiable: true),
      ),
    );
  }

  void listItemDeleteAction(BuildContext context, Exercise exercise) {
    int exerciseId = exercise.id!;
    GetIt.I.get<Repository>()
        .countExerciseSets(exerciseId)
        .then((count) {
      _showDialogAndDeleteExercise(context, count, exerciseId);
    });
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
                  GetIt.I.get<Repository>()
                      .deleteExercise(exerciseId)
                      .then((deletedCount) {
                    if (deletedCount > 0) {
                      setState(() {
                        entities = null;
                        entitiesReady = false;
                      });
                    }
                  });
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
}
