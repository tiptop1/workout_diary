import 'package:flutter/material.dart';
import 'package:workout_diary/src/config.dart';

import '../domain.dart';
import '../repository.dart';
import 'exercise_widgets.dart';
import 'progress_widget.dart';

class AllExercisesTabWidget extends StatefulWidget {
  AllExercisesTabWidget({Key? key}) : super(key: key);

  @override
  State<AllExercisesTabWidget> createState() => _AllExercisesState();
}

class _AllExercisesState extends State<AllExercisesTabWidget> {
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
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _exercises!.length,
      itemBuilder: (BuildContext context, int index) {
        return Card(
          child: ListTile(
            title: Text(_exercises![index].name),
            trailing: Icon(Icons.menu_rounded),
            onTap: () {
              var sharedPrefs = Configuration.of(context).sharedPreferences;
              var db = Repository.of(context).database;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Configuration(
                    sharedPreferences: sharedPrefs,
                    child: Repository(
                      database: db,
                      child: ShowExerciseWidget(
                          key: UniqueKey(), exerciseId: _exercises![index].id!),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
