import 'package:equatable/equatable.dart';

import 'exercise.dart';
import 'workout.dart';

class ExerciseSet extends Equatable {
  final Exercise exercise;
  final Workout workout;
  final int orderNumber;
  final String? details;

  const ExerciseSet(
      {required this.exercise, required this.workout, this.orderNumber = 0, this.details});

  @override
  List<Object> get props => [exercise, workout, orderNumber];

  @override
  bool get stringify => true;
}
