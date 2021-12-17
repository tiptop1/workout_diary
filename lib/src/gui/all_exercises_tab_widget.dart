import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:workout_diary/src/config.dart';

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

  @override
  Widget build(BuildContext context) {
    var widget;
    if (_exercises == null) {
      Repository.of(context)
          .finaAllExerciseSummaries()
          .then((List<Exercise> exercises) {
        setState(() {
          _exercises = exercises;
        });
      });
      widget = ProgressWidget();
    } else {
      widget = _build(context);
    }
    return widget;
  }

  Widget _build(BuildContext context) {
    AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _exercises!.length,
      itemBuilder: (BuildContext context, int index) {
        return Card(
          child: ListTile(
            title: Text(_exercises![index].name),
            // trailing: Icon(Icons.menu_rounded),
            trailing: PopupMenuButton<ExerciseAction>(
              icon: Icon(Icons.menu_rounded),
              onSelected: (ExerciseAction result) {
                if (result == ExerciseAction.modify) {
                } else if (result == ExerciseAction.delete) {}
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
              var sharedPrefs = Configuration.of(context).sharedPreferences;
              var db = Repository.of(context).database;
              push(
                context,
                child: ShowExerciseWidget(
                    key: UniqueKey(), exerciseId: _exercises![index].id!),
              );
            },
          ),
        );
      },
    );
  }
}
