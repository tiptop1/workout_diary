import 'package:floor/floor.dart';

import '../model/exercise_set_model.dart';

@dao
abstract class ExerciseSetDao {
  @Query(
      'SELECT * FROM ExerciseSetModel WHERE workoutId = :workoutId ORDER BY orderNumber')
  Future<List<ExerciseSetModel>> findExerciseSetsByWorkoutId(int workoutId);

  @insert
  Future<int> insertExerciseSet(ExerciseSetModel exerciseSet);

  @update
  Future<void> updateExerciseSet(ExerciseSetModel exerciseSet);

  @delete
  Future<void> deleteExerciseSet(ExerciseSetModel exerciseSet);
}
