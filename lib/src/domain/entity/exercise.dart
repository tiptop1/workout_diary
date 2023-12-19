import 'package:equatable/equatable.dart';

class ExerciseId extends Equatable {
  final int id;

  const ExerciseId(this.id);

  @override
  List<Object> get props => [id];

  @override
  bool get stringify => true;
}

class Exercise extends Equatable {
  final ExerciseId id;
  final String name;
  final String? description;

  const Exercise({
    required this.id,
    required this.name,
    this.description,
  });

  @override
  List<Object> get props => [id];

  @override
  bool get stringify => true;
}
