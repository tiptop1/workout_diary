import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:workout_diary/src/gui/list_tab_widget.dart';
import 'package:workout_diary/src/gui/workout_widgets.dart';

import '../model/repository.dart';
import '../model/workout.dart';

class AllWorkoutsTabWidget extends ListOnTabWidget {
  const AllWorkoutsTabWidget({Key? key}) : super(key: key);

  @override
  State<AllWorkoutsTabWidget> createState() => _AllWorkoutsState();
}

class _AllWorkoutsState extends ListOnTabState<AllWorkoutsTabWidget, Workout> {
  @override
  void loadEntities(BuildContext context) {
    GetIt.I
        .get<Repository>()
        .findAllWorkoutSummaries()
        .then((List<Workout> workouts) {
      setState(() {
        entities = workouts;
        entitiesReady = true;
      });
    }).catchError((error) {
      log('Can not load exercises!');
    });
  }

  @override
  Widget listItemTitle(BuildContext context, Workout workout) {
    var startTime = workout.startTime;
    var startTimeStr = startTime != null
        ? dateTimeStr(Localizations.localeOf(context), startTime)
        : dateLackMarker;

    return Text(
        startTime != null ? '${workout.title} ($startTimeStr)' : workout.title);
  }

  @override
  void listItemModifyAction(BuildContext context, Workout workout) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Workout modify action not implemented yet!'),
    ));
  }

  @override
  void listItemDeleteAction(BuildContext context, Workout workout) {
    _showDeleteDialog(context, workout.id!);
  }

  @override
  void listItemShowAction(BuildContext context, Workout workout) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Workout show action not implemented yet!'),
    ));
  }

  void _showDeleteDialog(BuildContext context, int workoutId) {
    AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return AlertDialog(
            title: Text(appLocalizations.workoutDeleteTitle),
            content: _buildDialogContent(appLocalizations),
            actions: <Widget>[
              TextButton(
                child: Text(appLocalizations.yes),
                onPressed: () {
                  GetIt.I
                      .get<Repository>()
                      .deleteWorkout(workoutId)
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

  Widget _buildDialogContent(AppLocalizations appLocalizations) {
    return Row(children: [
      Expanded(
          flex: 20,
          child: FittedBox(
              fit: BoxFit.fill,
              child: Icon(
                Icons.help,
                color: Colors.yellow,
              ))),
      Spacer(flex: 2),
      Expanded(
        flex: 60,
        child: Text(appLocalizations.workoutDeleteInfo),
      ),
    ]);
  }
}
