import 'package:floor/floor.dart';

import '../model/exercise_set_model.dart';

@dao
abstract class ExerciseSetDao {
  @Query('SELECT * FROM ExerciseSetModel WHERE id = :id')
  Future<ExerciseSetModel?> findExerciseSetById(int id);

  @Query(
      'SELECT * FROM ExerciseSetModel WHERE workoutId = :workoutId ORDER BY orderNumber')
  Future<List<ExerciseSetModel>> findExerciseSetsByWorkoutId(int workoutId);

  @Query('SELECT max(id) FROM ExerciseSetModel')
  Future<int?> maxId();

  @insert
  Future<int> insertExerciseSet(ExerciseSetModel exerciseSet);

  @update
  Future<int> updateExerciseSet(ExerciseSetModel exerciseSet);

  @delete
  Future<int> deleteExerciseSet(ExerciseSetModel exerciseSet);
}
