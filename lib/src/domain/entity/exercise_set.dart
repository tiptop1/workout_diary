import 'package:equatable/equatable.dart';

import 'exercise.dart';

class ExerciseSetId extends Equatable {
  final int id;

  const ExerciseSetId(this.id);

  @override
  List<Object> get props => [id];

  @override
  bool get stringify => true;
}

class ExerciseSet extends Equatable {
  final ExerciseSetId id;
  final Exercise exercise;
  final int orderNumber;
  final String? details;

  const ExerciseSet({
    required this.id,
    required this.exercise,
    this.orderNumber = 0,
    this.details,
  });

  @override
  List<Object> get props => [id];

  @override
  bool get stringify => true;
}
