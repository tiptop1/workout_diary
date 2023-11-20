import 'package:dartz/dartz.dart';

import '../../common/failures.dart';
import '../entities/exercise.dart';
import '../repositories/repository.dart';

class ExerciseUseCases {
  final Repository repository;

  const ExerciseUseCases(this.repository);

  Future<Either<Failure, List<Exercise>>> getAllExercises() async {
    return await repository.getAllExercises();
  }

  Future<Either<Failure, void>> addExercise(Exercise exercise) async {
    return await repository.addExercise(exercise);
  }

  Future<Either<Failure, void>> removeExercise(String name) async {
    return await repository.removeExercise(name);
  }

  Future<Either<Failure, void>> modifyExercise(Exercise exercise) async {
    return await repository.modifyExercise(exercise);
  }

  Future<Either<Failure, Exercise>> getExerciseDetails(String name) async {
    return await repository.getExerciseDetails(name);
  }
}
