import 'package:floor/floor.dart';
import '../model/exercise_model.dart';

@dao
abstract class ExerciseDao {
  @Query('SELECT * FROM ExerciseModel ORDER BY name')
  Future<List<ExerciseModel>> findAllExercises();

  @Query('SELECT * FROM ExerciseModel WHERE id = :id')
  Future<ExerciseModel?> findExerciseById(int id);

  @Query('SELECT max(id) FROM ExrciseModel')
  Future<int?> maxId();

  @insert
  Future<int> insertExercise(ExerciseModel exercise);

  @update
  Future<int> updateExercise(ExerciseModel exercise);

  @delete
  Future<int> deleteExercise(ExerciseModel exercise);
}
