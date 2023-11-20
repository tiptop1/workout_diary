import 'package:floor/floor.dart';

import '../entities/exercise_set.dart';

@dao
abstract class ExerciseSetDao {
  @Query('SELECT * FROM ExerciseSet WHERE workoutId = :workoutId ORDER BY orderNumber')
  Future<List<ExerciseSet>> findExerciseSetsByWorkoutId(int workoutId);

  @insert
  Future<ExerciseSet> insertExerciseSet(ExerciseSet exerciseSet);

  @update
  Future<void> updateExerciseSet(ExerciseSet exerciseSet);

  @delete
  Future<void> deleteExerciseSet(ExerciseSet exerciseSet);

}