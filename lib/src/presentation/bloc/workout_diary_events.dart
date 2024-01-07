import '../../domain/entity/exercise.dart';
import '../../domain/entity/workout.dart';

abstract class WorkoutDiaryEvent {
  const WorkoutDiaryEvent();
}

class LoadData extends WorkoutDiaryEvent {
  const LoadData();
}

class ShowMainPage extends WorkoutDiaryEvent {
  const ShowMainPage();
}

class GetAllExercises extends WorkoutDiaryEvent {
  const GetAllExercises();
}

class GetExercise extends WorkoutDiaryEvent {
  final ExerciseId exerciseId;

  const GetExercise(this.exerciseId);
}

class AddExercise extends WorkoutDiaryEvent {
  final Exercise exercise;

  const AddExercise(this.exercise);
}

class ModifyExercise extends WorkoutDiaryEvent {
  final Exercise exercise;

  const ModifyExercise(this.exercise);
}

class RemoveExercise extends WorkoutDiaryEvent {
  final Exercise exercise;

  const RemoveExercise(this.exercise);
}

class GetAllWorkouts extends WorkoutDiaryEvent {
  const GetAllWorkouts();
}

class GetWorkout extends WorkoutDiaryEvent {
  final WorkoutId workoutId;

  const GetWorkout(this.workoutId);
}

class AddWorkout extends WorkoutDiaryEvent {
  final Workout workout;

  const AddWorkout(this.workout);
}

class ModifyWorkout extends WorkoutDiaryEvent {
  final Workout workout;

  const ModifyWorkout(this.workout);
}

class RemoveWorkout extends WorkoutDiaryEvent {
  final Workout workout;

  const RemoveWorkout(this.workout);
}