import 'package:equatable/equatable.dart';

import 'exercise_set.dart';

class WorkoutId extends Equatable {
  final int id;

  const WorkoutId(this.id);

  @override
  List<Object> get props => [id];

  @override
  bool get stringify => true;
}

class Workout extends Equatable {
  final WorkoutId id;
  final String title;
  final DateTime startTime;
  final DateTime? endTime;
  final String? comment;
  final List<ExerciseSet> exerciseSets;

  const Workout({
    required this.id,
    required this.title,
    required this.startTime,
    this.endTime,
    this.comment,
    this.exerciseSets = const [],
  });

  @override
  List<Object> get props => [id];

  @override
  bool get stringify => true;
}
