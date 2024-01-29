import 'package:floor/floor.dart';

import '../model/workout_model.dart';

@dao
abstract class WorkoutDao {
  @Query('SELECT * FROM workouts')
  Future<List<WorkoutModel>> findAllWorkouts();

  @Query('SELECT * FROM workouts WHERE id = :id')
  Future<WorkoutModel?> findWorkoutById(int id);

  @Query('SELECT max(id) FROM workouts')
  Future<int?> maxId();

  @insert
  Future<int> insertWorkout(WorkoutModel workout);

  @update
  Future<int> updateWorkout(WorkoutModel workout);

  @delete
  Future<int> deleteWorkout(WorkoutModel workout);
}
