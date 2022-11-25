import '../model/exercise.dart';
import '../model/workout.dart';

class LoadExercisesAction {
  final List<Exercise>? exercises;

  const LoadExercisesAction({this.exercises});
}

class LoadWorkoutsAction {
  final List<Workout>? workouts;

  const LoadWorkoutsAction({this.workouts});
}

class AddExerciseAction {
  final int? id;
  final Exercise? exercise;

  const AddExerciseAction({this.id, this.exercise});
}

class AddWorkoutAction {
  final int? id;
  final Workout? workout;

  const AddWorkoutAction({this.id, this.workout});
}

class ModifyExerciseAction {
  final Exercise exercise;

  const ModifyExerciseAction({required this.exercise});
}

class ModifyWorkoutAction {
  final Workout workout;

  const ModifyWorkoutAction({required this.workout});
}

class RemoveExerciseAction {
  final int id;

  const RemoveExerciseAction({required this.id});
}

class RemoveWorkoutAction {
  final int id;

  const RemoveWorkoutAction({required this.id});
}
