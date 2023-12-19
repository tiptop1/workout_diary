import 'package:fpdart/fpdart.dart';

import '../../common/failures.dart';
import '../entity/workout.dart';
import '../repository/repository.dart';

class WorkoutUseCases {
  final Repository repository;

  const WorkoutUseCases(this.repository);

  Future<Either<Failure, List<Workout>>> getAllWorkouts() async {
    return await repository.getAllWorkouts();
  }

  Future<Either<Failure, Workout>> getWorkout(WorkoutId id) async {
    return await repository.getWorkout(id);
  }

  Future<Either<Failure, void>> addWorkout(Workout workout) async {
    return await repository.addWorkout(workout);
  }

  Future<Either<Failure, void>> modifyWorkout(Workout workout) async {
    return await repository.modifyWorkout(workout);
  }

  Future<Either<Failure, void>> removeWorkout(Workout workout) async {
    return await repository.removeWorkout(workout);
  }
}
