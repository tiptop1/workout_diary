import 'package:dartz/dartz.dart';

import '../../common/failures.dart';
import '../entities/exercise.dart';
import '../entities/workout.dart';

abstract class Repository {
  Future<Either<Failure, List<Exercise>>> getAllExercises();

  Future<Either<Failure, void>> addExercise(Exercise exercise);

  Future<Either<Failure, void>> removeExercise(String name);

  Future<Either<Failure, void>> modifyExercise(Exercise exercise);

  Future<Either<Failure, Exercise>> getExerciseDetails(String name);

  Future<Either<Failure, List<Workout>>> getAllWorkouts();

  Future<Either<Failure, void>> addWorkout(Workout workout);

  Future<Either<Failure, void>> removeWorkout(String title, DateTime startTime);

  Future<Either<Failure, void>> modifyWorkout(Workout workout);

  Future<Either<Failure, Workout>> getWorkoutDetails(
      String title, DateTime startTime);
}
