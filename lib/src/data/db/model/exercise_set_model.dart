import 'package:equatable/equatable.dart';
import 'package:floor/floor.dart';

import 'exercise_model.dart';
import 'workout_model.dart';

@Entity(tableName: 'exercise_sets')
class ExerciseSetModel extends Equatable {
  @primaryKey
  final int id;
  @ForeignKey(
    childColumns: ['exerciseId'],
    parentColumns: ['id'],
    entity: ExerciseModel,
  )
  final int exerciseId;
  @ForeignKey(
    childColumns: ['workoutId'],
    parentColumns: ['id'],
    entity: WorkoutModel,
    onDelete: ForeignKeyAction.cascade,
  )
  final int workoutId;
  final int orderNumber;
  final String? details;

  const ExerciseSetModel({
    required this.id,
    required this.exerciseId,
    required this.workoutId,
    required this.orderNumber,
    this.details,
  });

  @override
  List<Object?> get props => [id];
}
