import 'package:floor/floor.dart';

import 'exercise.dart';
import 'workout.dart';

@entity
@Index(name: 'UX_exierciseSet_exercise_workout_orderNumber', value: ['exerciseId', 'workoutId', 'orderNumber'])
class ExerciseSet {
  @PrimaryKey(autoGenerate: true)
  final int id;
  @ForeignKey(
    childColumns: ['exerciseId'],
    parentColumns: ['id'],
    entity: Exercise,
  )
  final int exerciseId;
  @ForeignKey(
      childColumns: ['workoutId'],
      parentColumns: ['id'],
      entity: Workout,
      onDelete: ForeignKeyAction.cascade)
  final int workoutId;
  final int orderNumber;
  final String? details;

  const ExerciseSet(
      this.id, this.exerciseId, this.workoutId, this.orderNumber, this.details);
}
