import 'package:floor/floor.dart';
import 'exercise.dart';
import 'workout.dart';

@entity
@Index(name: 'UX_exierciseSet_exercise_workout_orderNumber', value: ['exerciseId', 'workoutId', 'orderNumber'])
class ExerciseSet {
  @PrimaryKey(autoGenerate: true)
  final int id;
  @ForeignKey(
    childColumns: ['exercise'],
    parentColumns: ['id'],
    entity: Exercise,
  )
  final Exercise exercise;
  @ForeignKey(
      childColumns: ['workout'],
      parentColumns: ['id'],
      entity: Workout,
      onDelete: ForeignKeyAction.cascade)
  final Workout workout;
  final int orderNumber;
  final String? details;

  const ExerciseSet(
      this.id, this.exercise, this.workout, this.orderNumber, this.details);
}
