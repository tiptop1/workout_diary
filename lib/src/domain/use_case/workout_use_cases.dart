import 'package:dartz/dartz.dart';

import '../../common/failures.dart';
import '../entity/workout.dart';
import '../repository/repository.dart';

class WorkoutUseCases {
  final Repository repository;

  const WorkoutUseCases(this.repository);

  Future<Either<Failure, List<Workout>>> getAllWorkouts() async {
    return await repository.getAllWorkouts();
  }

  Future<Either<Failure, Workout>> getWorkoutDetails(DateTime startTime) async {
    return await repository.getWorkout(startTime);
  }

  Future<Either<Failure, void>> addWorkout(Workout workout) async {
    return await repository.addWorkout(workout);
  }

  Future<Either<Failure, void>> modifyWorkout(Workout workout) async {
    return await repository.modifyWorkout(workout);
  }

  Future<Either<Failure, void>> removeWorkout(DateTime startTime) async {
    return await repository.removeWorkout(startTime);
  }
}
