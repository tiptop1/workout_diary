import 'package:flutter/material.dart';
import 'package:workout_diary/src/presentation/routes/abstract_tab_content.dart';

import '../../domain/entity/workout.dart';

class WorkoutsTabContent extends AbstractTabContent<Workout> {
  const WorkoutsTabContent({super.key, required List<Workout> workouts})
      : super(entities: workouts);

  @override
  void listItemDeleteAction(BuildContext context, Workout workout) {
    // TODO: implement listItemDeleteAction
  }

  @override
  void listItemModifyAction(BuildContext context, Workout workout) {
    // TODO: implement listItemModifyAction
  }

  @override
  void listItemShowAction(BuildContext context, Workout workout) {
    // TODO: implement listItemShowAction
  }

  @override
  Widget listItemTitle(BuildContext context, Workout workout) {
    // TODO: implement listItemTitle
    throw UnimplementedError();
  }
}
