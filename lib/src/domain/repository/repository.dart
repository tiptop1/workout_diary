import 'package:fpdart/fpdart.dart';
import 'package:workout_diary/src/domain/entity/exercise_set.dart';

import '../../common/failures.dart';
import '../entity/exercise.dart';
import '../entity/workout.dart';

abstract class Repository {
  Future<Either<Failure, ExerciseId>> nextExerciseId();

  Future<Either<Failure, List<Exercise>>> getAllExercises();

  Future<Either<Failure, Exercise>> getExercise(ExerciseId id);

  Future<Either<Failure, void>> addExercise(Exercise exercise);

  Future<Either<Failure, void>> removeExercise(Exercise exercise);

  Future<Either<Failure, void>> modifyExercise(Exercise exercise);

  Future<Either<Failure, WorkoutId>> nextWorkoutId();

  Future<Either<Failure, List<Workout>>> getAllWorkouts();

  Future<Either<Failure, Workout>> getWorkout(WorkoutId id);

  Future<Either<Failure, void>> addWorkout(Workout workout);

  Future<Either<Failure, void>> removeWorkout(Workout workout);

  Future<Either<Failure, void>> modifyWorkout(Workout workout);

  Future<Either<Failure, ExerciseSetId>> nextExerciseSetId();
}
