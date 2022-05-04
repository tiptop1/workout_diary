import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:workout_diary/src/gui/list_tab_widget.dart';
import 'package:workout_diary/src/gui/workout_widgets.dart';

import '../domain.dart';
import '../repository.dart';

class AllWorkoutsTabWidget extends ListOnTabWidget {
  AllWorkoutsTabWidget({Key? key}) : super(key: key);

  @override
  State<AllWorkoutsTabWidget> createState() => _AllWorkoutsState();
}

class _AllWorkoutsState extends ListOnTabState<AllWorkoutsTabWidget, Workout> {
  @override
  void loadEntities(BuildContext context) {
    Repository.of(context)
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Workout delete action not implemented yet!'),
    ));
  }

  @override
  void listItemShowAction(BuildContext context, Workout workout) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Workout show action not implemented yet!'),
    ));
  }
}
