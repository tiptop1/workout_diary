import 'package:floor/floor.dart';

import '../model/workout_model.dart';

@dao
abstract class WorkoutDao {
  @Query('SELECT * FROM WorkoutModel')
  Future<List<WorkoutModel>> findAllWorkouts();

  @Query('SELECT * FROM WorkoutModel WHERE id = :id')
  Future<WorkoutModel?> findWorkoutById(int id);

  @Query('SELECT max(id) FROM WorkoutModel')
  Future<int?> maxId();

  @insert
  Future<int> insertWorkout(WorkoutModel workout);

  @update
  Future<int> updateWorkout(WorkoutModel workout);

  @delete
  Future<int> deleteWorkout(WorkoutModel workout);
}
