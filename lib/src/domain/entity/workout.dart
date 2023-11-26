import 'package:equatable/equatable.dart';

import 'exercise_set.dart';

class Workout extends Equatable {
  final String title;
  final DateTime startTime;
  final DateTime? endTime;
  final String? comment;
  final List<ExerciseSet> exerciseSets;

  const Workout(
      {required this.title,
      required this.startTime,
      this.endTime,
      this.comment,
      this.exerciseSets = const []});

  @override
  List<Object> get props => [title, startTime, exerciseSets];

  @override
  bool get stringify => true;
}
