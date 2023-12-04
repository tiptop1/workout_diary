import 'package:floor/floor.dart';

import '../model/workout_model.dart';

@dao
abstract class WorkoutDao {
  @Query('SELECT * FROM WorkoutModel')
  Future<List<WorkoutModel>> findAllWorkouts();

  /// Find [WorkoutModel] by natural key [startTime].
  @Query('SELECT * FROM WorkoutModel WHERE startTime = :startTime')
  Future<WorkoutModel?> findWorkoutByStartTime(DateTime startTime);

  @insert
  Future<int> insertWorkout(WorkoutModel workout);

  @update
  Future<void> updateWorkout(WorkoutModel workout);

  @delete
  Future<void> deleteWorkout(WorkoutModel workout);
}
