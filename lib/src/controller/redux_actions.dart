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

class DeleteExerciseAction {
  final int exerciseId;

  const DeleteExerciseAction({required this.exerciseId});
}

class DeleteWorkoutAction {
  final int workoutId;

  const DeleteWorkoutAction({required this.workoutId});
}
