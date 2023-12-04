import 'package:floor/floor.dart';
import '../model/exercise_model.dart';

@dao
abstract class ExerciseDao {
  @Query('SELECT * FROM ExerciseModel ORDER BY name')
  Future<List<ExerciseModel>> findAllExercises();

  /// Find [ExerciseModel] by natural key [name].
  @Query('SELECT * FROM ExerciseModel WHERE name = :name')
  Future<ExerciseModel?> findExerciseByName(String name);

  @insert
  Future<int> insertExercise(ExerciseModel exercise);

  @update
  Future<void> updateExercise(ExerciseModel exercise);

  @delete
  Future<void> deleteExercise(ExerciseModel exercise);
}
