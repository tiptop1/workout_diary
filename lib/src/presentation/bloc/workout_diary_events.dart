import '../../domain/entity/exercise.dart';
import '../../domain/entity/exercise_set.dart';
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

class AddWorkoutEvent extends WorkoutDiaryEvent {
  final String title;
  final DateTime startTime;
  final DateTime? endTime;
  final String? comment;
  final List<ExerciseSet> exerciseSets;

  AddWorkoutEvent({
    required this.title,
    required this.startTime,
    this.endTime,
    this.comment,
    List<ExerciseSet> exerciseSets = const [],
  }) : exerciseSets = List.unmodifiable(exerciseSets);
}

class ModifyWorkoutEvent extends WorkoutDiaryEvent {
  final Workout workout;

  ModifyWorkoutEvent({required this.workout});
}

class DeleteWorkoutEvent extends WorkoutDiaryEvent {
  final Workout workout;

  const DeleteWorkoutEvent(this.workout);
}
