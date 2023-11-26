import 'package:floor/floor.dart';

import '../entity/workout.dart';

@dao
abstract class WorkoutDao {
  @Query('SELECT * FROM Workout')
  Future<List<Workout>> findAllWorkouts();

  @insert
  @transaction
  Future<int> insertWorkout(Workout workout);

  @update
  @transaction
  Future<void> updateWorkout(Workout workout);

  @delete
  @transaction
  Future<void> deleteWorkout(Workout workout);

}