import 'package:equatable/equatable.dart';
import 'package:floor/floor.dart';

import 'exercise_model.dart';
import 'workout_model.dart';

/// The entity is syntetic - there is no natural key
@Entity(tableName: 'exercise_sets')
@Index(
    name: 'UX_ExerciseSet_exercise_workout_orderNumber',
    value: ['exerciseId', 'workoutId', 'orderNumber'])
class ExerciseSetModel extends Equatable {
  @PrimaryKey(autoGenerate: true)
  final int? id;
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
      onDelete: ForeignKeyAction.cascade)
  final int workoutId;
  final int orderNumber;
  final String? details;

  const ExerciseSetModel(
      {this.id,
      required this.exerciseId,
      required this.workoutId,
      required this.orderNumber,
      this.details,});

  @override
  List<Object?> get props => [id, exerciseId, workoutId, orderNumber];
}
