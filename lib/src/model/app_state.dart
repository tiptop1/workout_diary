import 'exercise.dart';
import 'workout.dart';

class AppState {
  final List<Exercise> exercises;
  final List<Workout> workouts;

  AppState({required List<Exercise> exercises, required List<Workout> workouts})
      : this.exercises = List.unmodifiable(exercises),
        this.workouts = List.unmodifiable(workouts);
}
