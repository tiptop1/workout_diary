import 'package:fpdart/fpdart.dart';

import '../../common/failures.dart';
import '../entity/exercise.dart';
import '../repository/repository.dart';

class ExerciseUseCases {
  final Repository repository;

  const ExerciseUseCases(this.repository);

  Future<Either<Failure, List<Exercise>>> getAllExercises() async {
    return await repository.getAllExercises();
  }

  Future<Either<Failure, Exercise>> getExercise(ExerciseId id) async {
    return await repository.getExercise(id);
  }

  Future<Either<Failure, void>> addExercise(Exercise exercise) async {
    return await repository.addExercise(exercise);
  }

  Future<Either<Failure, void>> modifyExercise(Exercise exercise) async {
    return await repository.modifyExercise(exercise);
  }

  Future<Either<Failure, void>> removeExercise(Exercise exercise) async {
    return await repository.removeExercise(exercise);
  }
}
