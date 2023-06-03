import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:tuple/tuple.dart';

import '../model/app_state.dart';
import '../model/exercise.dart';
import '../model/exercise_set.dart';

class ExerciseSetsWidget extends StatefulWidget {
  final List<ExerciseSet> exerciseSets;

  const ExerciseSetsWidget({Key? key, required this.exerciseSets})
      : super(key: key);

  @override
  State<ExerciseSetsWidget> createState() => _ExerciseSetsWidgetState();
}

class _ExerciseSetsWidgetState extends State<ExerciseSetsWidget> {
  final List<Tuple2<Exercise, TextEditingController>> exerciseSetsTuples = [];

  @override
  void initState() {
    super.initState();
    for (var es in widget.exerciseSets) {
      exerciseSetsTuples.add(Tuple2(es.exercise, TextEditingController()));
    }
  }

  @override
  void dispose() {
    for (var t in exerciseSetsTuples) {
      t.item2.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, List<Exercise>>(
        converter: (store) => store.state.exercises,
        builder: (context, exercises) {
          return Column(
            children: [
              ListView.builder(
                itemBuilder: (buildContext, index) => _createExerciseSetTile(index, exercises, exerciseSetsTuples[index]),
              ),
            ],
          );
        });
  }

  Widget _createExerciseSetTile(int index, List<Exercise> exercises,
      Tuple2<Exercise, TextEditingController> workoutEntryTuple) {
    return ListTile(
      leading:
          _createExerciseDropDownButton(index, exercises, workoutEntryTuple),
      title: TextFormField(controller: workoutEntryTuple.item2),
    );
  }

  Widget _createExerciseDropDownButton(int index, List<Exercise> exercises,
      Tuple2<Exercise, TextEditingController> workoutEntryTuple) {
    return DropdownButton<int>(
        items:
            exercises.map((e) => _createExerciseDropdownMenuItem(e)).toList(),
        value: workoutEntryTuple.item1.id,
        onChanged: (int? newExerciseId) {
          setState(() {
            exerciseSetsTuples[index] = workoutEntryTuple.withItem1(exercises
                .firstWhere((exercise) => exercise.id == newExerciseId));
          });
        });
  }

  DropdownMenuItem<int> _createExerciseDropdownMenuItem(Exercise exercise) {
    return DropdownMenuItem<int>(
      value: exercise.id,
      child: Text(exercise.name),
    );
  }
}
