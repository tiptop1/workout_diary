import 'package:floor/floor.dart';
import '../entities/exercise.dart';

@dao
abstract class ExercisDao {
  @Query('SELECT * FROM Exercise')
  Future<List<Exercise>> findAllExercises();

  @insert
  Future<Exercise> insertExercise(Exercise exercise);

  @update
  Future<void> updateExercise(Exercise exercise);

  @delete
  Future<void> deleteExercise(Exercise exercise);

}