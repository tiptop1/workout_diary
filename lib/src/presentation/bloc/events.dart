import 'package:equatable/equatable.dart';

import '../../domain/entity/exercise.dart';
import '../../domain/entity/workout.dart';

abstract class Event extends Equatable {
  const Event();

  @override
  List<Object?> get props => [];
}

class GetAllExercises extends Event {
  const GetAllExercises();
}

class GetExercise extends Event {
  final ExerciseId exerciseId;

  const GetExercise(this.exerciseId);
}

class AddExercise extends Event {
  final Exercise exercise;

  const AddExercise(this.exercise);
}

class ModifyExercise extends Event {
  final Exercise exercise;

  const ModifyExercise(this.exercise);
}

class RemoveExercise extends Event {
  final Exercise exercise;

  const RemoveExercise(this.exercise);
}

class GetAllWorkouts extends Event {
  const GetAllWorkouts();
}

class GetWorkout extends Event {
  final WorkoutId workoutId;

  const GetWorkout(this.workoutId);
}

class AddWorkout extends Event {
  final Workout workout;

  const AddWorkout(this.workout);
}

class ModifyWorkout extends Event {
  final Workout workout;

  const ModifyWorkout(this.workout);
}

class RemoveWorkout extends Event {
  final Workout workout;

  const RemoveWorkout(this.workout);
}