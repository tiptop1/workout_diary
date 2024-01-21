import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:workout_diary/src/presentation/bloc/main_route_bloc.dart';
import 'package:workout_diary/src/presentation/routes/abstract_tab_content.dart';

import '../../domain/entity/exercise.dart';
import '../bloc/workout_diary_events.dart';
import 'exercise_route.dart';

class ExercisesTabContent extends AbstractTabContent<Exercise> {
  const ExercisesTabContent({super.key, required List<Exercise> exercises})
      : super(entities: exercises);

  @override
  void listItemDeleteAction(BuildContext context, Exercise entity) {
    BlocProvider.of<MainRouteBloc>(context).add(DeleteExerciseEvent(entity));
  }

  @override
  void listItemModifyAction(BuildContext context, Exercise entity) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseRoute(
          key: UniqueKey(),
          exercise: entity,
          modifiable: true,
        ),
      ),
    ).then((exercise) => BlocProvider.of<MainRouteBloc>(context)
        .add(ModifyExerciseEvent(exercise)));
  }

  @override
  void listItemShowAction(BuildContext context, Exercise entity) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseRoute(
          key: UniqueKey(),
          exercise: entity,
          modifiable: false,
        ),
      ),
    );
  }

  @override
  Widget listItemTitle(BuildContext context, Exercise entity) =>
      Text(entity.name);
}
