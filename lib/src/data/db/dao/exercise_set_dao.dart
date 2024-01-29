import 'package:floor/floor.dart';

import '../model/exercise_set_model.dart';

@dao
abstract class ExerciseSetDao {
  @Query('SELECT * FROM exercise_sets WHERE id = :id')
  Future<ExerciseSetModel?> findExerciseSetById(int id);

  @Query(
      'SELECT * FROM exercise_sets WHERE workoutId = :workoutId ORDER BY orderNumber')
  Future<List<ExerciseSetModel>> findExerciseSetsByWorkoutId(int workoutId);

  @Query('SELECT max(id) FROM exercise_sets')
  Future<int?> maxId();

  @insert
  Future<int> insertExerciseSet(ExerciseSetModel exerciseSet);

  @update
  Future<int> updateExerciseSet(ExerciseSetModel exerciseSet);

  @delete
  Future<int> deleteExerciseSet(ExerciseSetModel exerciseSet);
}
