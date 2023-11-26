import 'package:floor/floor.dart';

import '../entity/exerciseset.dart';

@dao
abstract class ExerciseSetDao {
  @Query('SELECT * FROM ExerciseSet WHERE workoutId = :workoutId ORDER BY orderNumber')
  Future<List<ExerciseSet>> findExerciseSetsByWorkoutId(int workoutId);

  @insert
  Future<int> insertExerciseSet(ExerciseSet exerciseSet);

  @update
  Future<void> updateExerciseSet(ExerciseSet exerciseSet);

  @delete
  Future<void> deleteExerciseSet(ExerciseSet exerciseSet);

}