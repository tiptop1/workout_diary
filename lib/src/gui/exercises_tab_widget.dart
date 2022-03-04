import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:workout_diary/src/gui/list_tab_widget.dart';

import '../domain.dart';
import '../repository.dart';
import 'exercise_widgets.dart';

enum ExerciseAction { modify, delete }

class AllExercisesTabWidget extends ListOnTabWidget {
  AllExercisesTabWidget({Key? key}) : super(key: key);

  @override
  State<AllExercisesTabWidget> createState() => _AllExercisesState();
}

class _AllExercisesState extends ListOnTabState<AllExercisesTabWidget> {
  @override
  void loadEntities(BuildContext context) {
    Repository.of(context)
        .findAllExerciseSummaries()
        .then((List<Exercise> exercises) {
      setState(() {
        entities = exercises;
        entitiesReady = true;
      });
    });
  }

  Widget? listTileTitleWidget(BuildContext context, Entity entity) =>
      Text((entity as Exercise).name);

  Widget? listTitleLeadingWidget(BuildContext contet, Entity entity) => null;

  void listItemModifyAction(BuildContext context, Entity entity) {
    push(
      context,
      child: ModifyExerciseWidget(key: UniqueKey(), exerciseId: entity.id!),
    );
  }

  void listItemDeleteAction(BuildContext context, Entity entity) {
    int exerciseId = entity.id!;
    Repository.of(context)
        .countWorkoutExercisesByExercise(exerciseId)
        .then((count) {
      _showDialogAndDeleteExercise(context, count, exerciseId);
    });
  }

  void listItemShowAction(BuildContext context, Entity entity) {
    push(
      context,
      child: ShowExerciseWidget(key: UniqueKey(), exerciseId: entity.id!),
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
          child:
              FittedBox(fit: BoxFit.fill, child: Icon(icon, color: iconColor))),
      Spacer(flex: 2),
      Expanded(flex: 60, child: Text(msg)),
    ]);
  }
}
