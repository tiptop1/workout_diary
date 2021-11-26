import 'package:flutter/material.dart';

import '../domain.dart';
import '../repository.dart';
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
          ),
        );
      },
    );
  }
}
