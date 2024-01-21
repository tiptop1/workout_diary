import 'package:equatable/equatable.dart';
import 'package:workout_diary/src/common/failures.dart';

import '../../domain/entity/exercise.dart';
import '../../domain/entity/workout.dart';

sealed class WorkoutDiaryState extends Equatable {
  const WorkoutDiaryState();

  @override
  List<Object?> get props => [];
}

class ProgressIndicatorState extends WorkoutDiaryState {}

class MainRouteState extends WorkoutDiaryState {
  final List<Exercise> exercises;
  final List<Workout> workouts;

  const MainRouteState(this.exercises, this.workouts);

  @override
  List<Object?> get props => [exercises, workouts];
}

class ErrorMessageState extends WorkoutDiaryState {
  final FailureCode code;
  final String? details;
  final Object? cause;

  const ErrorMessageState(this.code, this.details, this.cause);

  @override
  List<Object?> get props => [code, details, cause];
}
