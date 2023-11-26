import 'package:floor/floor.dart';
import '../entity/exercise.dart';

@dao
abstract class ExerciseDao {
  @Query('SELECT * FROM Exercise')
  Future<List<Exercise>> findAllExercises();

  @insert
  Future<int> insertExercise(Exercise exercise);

  @update
  Future<void> updateExercise(Exercise exercise);

  @delete
  Future<void> deleteExercise(Exercise exercise);

}