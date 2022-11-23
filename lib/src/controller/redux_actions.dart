import '../model/exercise.dart';
import '../model/workout.dart';

class LoadExercises {
  final List<Exercise>? exercises;

  const LoadExercises({this.exercises});
}

class LoadWorkouts {
  final List<Workout>? workouts;

  const LoadWorkouts({this.workouts});
}

class AddExercise {
  final int? id;
  final Exercise? exercise;

  const AddExercise({this.id, this.exercise});
}

class AddWorkout {
  final int? id;
  final Workout? workout;

  const AddWorkout({this.id, this.workout});
}

class ModifyExercise {
  final Exercise exercise;

  const ModifyExercise({required this.exercise});
}

class ModifyWorkout {
  final Workout workout;

  const ModifyWorkout({required this.workout});
}

class RemoveExercise {
  final int id;

  const RemoveExercise({required this.id});
}

class RemoveWorkout {
  final int id;

  const RemoveWorkout({required this.id});
}
