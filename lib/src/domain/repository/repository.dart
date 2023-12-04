import 'package:dartz/dartz.dart';

import '../../common/failures.dart';
import '../entity/exercise.dart';
import '../entity/workout.dart';

abstract class Repository {
  Future<Either<Failure, List<Exercise>>> getAllExercises();

  Future<Either<Failure, Exercise>> getExercise(String name);

  Future<Either<Failure, void>> addExercise(Exercise exercise);

  Future<Either<Failure, void>> removeExercise(String name);

  Future<Either<Failure, void>> modifyExercise(Exercise exercise);

  Future<Either<Failure, List<Workout>>> getAllWorkouts();

  Future<Either<Failure, Workout>> getWorkout(DateTime startTime);

  Future<Either<Failure, void>> addWorkout(Workout workout);

  Future<Either<Failure, void>> removeWorkout(DateTime startTime);

  Future<Either<Failure, void>> modifyWorkout(Workout workout);
}
