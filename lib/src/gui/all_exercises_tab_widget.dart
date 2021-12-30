import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../domain.dart';
import '../repository.dart';
import '../utils.dart';
import 'exercise_widgets.dart';
import 'progress_widget.dart';

enum ExerciseAction { modify, delete }

class AllExercisesTabWidget extends StatefulWidget {
  AllExercisesTabWidget({Key? key}) : super(key: key);

  @override
  State<AllExercisesTabWidget> createState() => _AllExercisesState();
}

class _AllExercisesState extends State<AllExercisesTabWidget>
    with NavigatorUtils {
  List<Exercise>? _exercises;
  bool _exercisesReady = false;

  @override
  Widget build(BuildContext context) {
    if (_exercises == null) {
      Repository.of(context)
          .finaAllExerciseSummaries()
          .then((List<Exercise> exercises) {
        setState(() {
          _exercises = exercises;
          _exercisesReady = true;
        });
      });
    }

    var widget;
    if (_exercisesReady) {
      widget = _build(context);
    } else {
      widget = ProgressWidget();
    }
    return widget;
  }

  Widget _build(BuildContext context) {
    AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _exercises!.length,
      itemBuilder: (BuildContext context, int index) {
        Exercise exercise = _exercises![index];
        return Card(
          child: ListTile(
            title: Text(exercise.name),
            // trailing: Icon(Icons.menu_rounded),
            trailing: PopupMenuButton<ExerciseAction>(
              icon: Icon(Icons.menu_rounded),
              onSelected: (ExerciseAction result) {
                if (result == ExerciseAction.modify) {
                  push(
                    context,
                    child: ModifyExerciseWidget(
                        key: UniqueKey(), exerciseId: exercise.id!),
                  );
                } else if (result == ExerciseAction.delete) {
                  Repository.of(context)
                      .countWorkoutExercisesByExercise(exercise.id!)
                      .then((count) {
                    _showDialogAndDeleteExercise(context, count, exercise.id!);
                  });
                }
              },
              itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<ExerciseAction>>[
                PopupMenuItem<ExerciseAction>(
                  value: ExerciseAction.modify,
                  child: Text(appLocalizations.modify),
                ),
                PopupMenuItem<ExerciseAction>(
                  value: ExerciseAction.delete,
                  child: Text(appLocalizations.delete),
                ),
              ],
            ),
            onTap: () {
              push(
                context,
                child: ShowExerciseWidget(
                    key: UniqueKey(), exerciseId: exercise.id!),
              );
            },
          ),
        );
      },
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
                  Repository.of(context)
                      .deleteExercise(exerciseId)
                      .then((deletedCount) {
                    if (deletedCount > 0) {
                      setState(() {
                        _exercises = null;
                        _exercisesReady = false;
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
      Expanded(flex: 20, child: FittedBox(fit: BoxFit.fill, child: Icon(icon, color: iconColor))),
      Spacer(flex: 2),
      Expanded(flex: 60, child: Text(msg)),
    ]);
  }
}
