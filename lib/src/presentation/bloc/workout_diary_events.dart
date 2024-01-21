import '../../domain/entity/exercise.dart';
import '../../domain/entity/workout.dart';

abstract class WorkoutDiaryEvent {
  const WorkoutDiaryEvent();
}

class ShowMainRouteEvent extends WorkoutDiaryEvent {
  const ShowMainRouteEvent();
}

class AddExerciseEvent extends WorkoutDiaryEvent {
  final String name;
  final String? description;

  const AddExerciseEvent(this.name, this.description);
}

class ModifyExerciseEvent extends WorkoutDiaryEvent {
  final Exercise exercise;

  const ModifyExerciseEvent(this.exercise);
}

class DeleteExerciseEvent extends WorkoutDiaryEvent {
  final Exercise exercise;

  const DeleteExerciseEvent(this.exercise);
}

class DeleteWorkoutEvent extends WorkoutDiaryEvent {
  final Workout workout;

  const DeleteWorkoutEvent(this.workout);
}
