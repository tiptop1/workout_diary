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

  Future<Either<Failure, void>> addExercise(
      String name, String? description) async {
    return (await _nextExerciseId()).fold(
      (failure) => Left(failure),
      (exerciseId) async => (await repository.addExercise(Exercise(
        id: exerciseId,
        name: name,
        description: description,
      )))
          .fold((failure) => Left(failure), (_) => const Right(null)),
    );
  }

  Future<Either<Failure, void>> modifyExercise(Exercise exercise) async {
    return await repository.modifyExercise(exercise);
  }

  Future<Either<Failure, void>> removeExercise(Exercise exercise) async {
    return await repository.removeExercise(exercise);
  }

  Future<Either<Failure, ExerciseId>> _nextExerciseId() async {
    return await repository.nextExerciseId();
  }
}
