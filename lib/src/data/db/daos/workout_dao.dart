import 'package:floor/floor.dart';

import '../entities/workout.dart';

@dao
abstract class WorkoutDao {
  @Query('SELECT * FROM Workout')
  Future<List<Workout>> findAllWorkouts();

  @insert
  Future<Workout> insertWorkout(Workout workout);

  @update
  Future<void> updateWorkout(Workout workout);

  @delete
  Future<void> deleteWorkout(Workout workout);

}