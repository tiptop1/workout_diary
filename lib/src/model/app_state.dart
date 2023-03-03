import 'exercise.dart';
import 'workout.dart';

class AppState {
  final List<Exercise> exercises;
  final List<Workout> workouts;

  AppState({required List<Exercise> exercises, required List<Workout> workouts})
      : exercises = List.unmodifiable(exercises),
        workouts = List.unmodifiable(workouts);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppState &&
          runtimeType == other.runtimeType &&
          exercises == other.exercises &&
          workouts == other.workouts;

  @override
  int get hashCode => exercises.hashCode ^ workouts.hashCode;
}
