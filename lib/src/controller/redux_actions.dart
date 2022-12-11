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
  final Exercise exercise;

  const AddExerciseAction({required this.exercise});
}

class AddWorkoutAction {
  final Workout workout;

  const AddWorkoutAction({required this.workout});
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
  final int exerciseId;

  const RemoveExerciseAction({required this.exerciseId});
}

class RemoveWorkoutAction {
  final int workoutId;

  const RemoveWorkoutAction({required this.workoutId});
}
