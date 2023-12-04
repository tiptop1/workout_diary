import 'package:dartz/dartz.dart';
import '../../domain/entity/exercise.dart';
import '../../domain/entity/workout.dart';
import '../../domain/repository/repository.dart';

import '../../common/failures.dart';
import 'model/exercise_model.dart';
import 'model/workout_model.dart';
import 'model/exercise_set_model.dart';
import 'workout_diary_database.dart';

class LocalFloorRepository implements Repository {
  final WorkoutDiaryDatabase database;

  LocalFloorRepository(this.database);

  @override
  Future<Either<Failure, void>> addExercise(Exercise exercise) async {
    Either<Failure, void> result;
    try {
      var exerciseModel = ExerciseModel(
        name: exercise.name,
        description: exercise.description,
      );
      await database.exerciseDao.insertExercise(exerciseModel);
      result = const Right(null);
    } catch (e) {
      result = Left(DatabaseError(
        details: 'Could not add exercise with name "${exercise.name}".',
        cause: e,
      ));
    }
    return result;
  }

  @override
  Future<Either<Failure, void>> addWorkout(Workout workout) async {
    Either<Failure, void> result;
    try {
      var workoutModel = WorkoutModel(
        title: workout.title,
        startTime: workout.startTime,
        endTime: workout.endTime,
        comment: workout.comment,
      );
      int workoutId = await database.workoutDao.insertWorkout(workoutModel);
      var exerciseIds = <String, int>{};
      for (var exerciseSet in workout.exerciseSets) {
        var exerciseName = exerciseSet.exercise.name;
        if (!exerciseIds.containsKey(exerciseName)) {
          // TODO: In future replace findExerciseByName() with method returning list of exercise in one shoot.
          var exerciseId =
              (await database.exerciseDao.findExerciseByName(exerciseName))?.id;
          if (exerciseId != null) {
            exerciseIds[exerciseName] = exerciseId;
          } else {
            result = Left(DatabaseError(
                details: 'No exercise with name "$exerciseName".'));
          }
        }
        database.exerciseSetDao.insertExerciseSet(ExerciseSetModel(
          exerciseId: exerciseIds[exerciseName]!,
          workoutId: workoutId,
          orderNumber: exerciseSet.orderNumber,
          details: exerciseSet.details,
        ));
      }
      result = const Right(null);
    } catch (e) {
      result = Left(DatabaseError(
        details: 'Could not add workout.',
        cause: e,
      ));
    }
    return result;
  }

  @override
  Future<Either<Failure, List<Exercise>>> getAllExercises() async {
    Either<Failure, List<Exercise>> result;
    try {
      var exerciseModels = await database.exerciseDao.findAllExercises();
      result = Right(exerciseModels
          .map((e) => Exercise(
                name: e.name,
                description: e.description,
              ))
          .toList(growable: false));
    } catch (e) {
      result = Left(DatabaseError(
        details: 'Could not get all exercises.',
        cause: e,
      ));
    }
    return result;
  }

  @override
  Future<Either<Failure, List<Workout>>> getAllWorkouts() async {
    Either<Failure, List<Workout>> result;
    try {
      var workoutModels = await database.workoutDao.findAllWorkouts();
      result = Right(workoutModels
          .map((workoutModel) => Workout(
                title: workoutModel.title,
                startTime: workoutModel.startTime,
                endTime: workoutModel.endTime,
                comment: workoutModel.comment,
              ))
          .toList(growable: false));
    } catch (e) {
      result = Left(DatabaseError(
        details: 'Could not get all workouts.',
        cause: e,
      ));
    }
    return result;
  }

  @override
  Future<Either<Failure, Exercise>> getExercise(String name) async {
    Either<Failure, Exercise> result;
    try {
      var exerciseModel = await database.exerciseDao.findExerciseByName(name);
      if (exerciseModel != null) {
        var exercise = Exercise(
          name: exerciseModel.name,
          description: exerciseModel.description,
        );
        result = Right(exercise);
      } else {
        result = Left(DatabaseError(details: 'No exercise with name "$name".'));
      }
    } catch (e) {
      result = Left(DatabaseError(
        details: 'Could not get exercise with name "$name".',
        cause: e,
      ));
    }
    return result;
  }

  @override
  Future<Either<Failure, Workout>> getWorkout(DateTime startTime) async {
    Either<Failure, Workout> result;
    try {
      var workoutModel =
          await database.workoutDao.findWorkoutByStartTime(startTime);
      if (workoutModel != null) {
        var workout = Workout(
          title: workoutModel.title,
          startTime: workoutModel.startTime,
        );
        result = Right(workout);
      } else {
        result = Left(DatabaseError(
          details: 'No workout for start time "$startTime".',
        ));
      }
    } catch (e) {
      result = Left(DatabaseError(
        details: 'Could not get workout with start time "$startTime".',
        cause: e,
      ));
    }
    return result;
  }

  @override
  Future<Either<Failure, void>> modifyExercise(Exercise exercise) async {
    Either<Failure, void> result;
    try {
      var exerciseModel =
          await database.exerciseDao.findExerciseByName(exercise.name);
      if (exerciseModel != null) {
        await database.exerciseDao.updateExercise(exerciseModel);
      }
      result = const Right(null);
    } catch (e) {
      result = Left(DatabaseError(
        details: 'Could not modify exercise with name "${exercise.name}".',
        cause: e,
      ));
    }
    return result;
  }

  @override
  Future<Either<Failure, void>> modifyWorkout(Workout workout) {
    // TODO: implement modifyWorkout
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> removeExercise(String name) async {
    Either<Failure, void> result;
    try {
      var exerciseModel = await database.exerciseDao.findExerciseByName(name);
      if (exerciseModel != null) {
        await database.exerciseDao.deleteExercise(exerciseModel);
      }
      result = const Right(null);
    } catch (e) {
      result = Left(DatabaseError(
        details: 'Could not remove exercise with name "$name".',
        cause: e,
      ));
    }
    return result;
  }

  @override
  Future<Either<Failure, void>> removeWorkout(DateTime startTime) async {
    Either<Failure, void> result;
    try {
      var workoutModel =
          await database.workoutDao.findWorkoutByStartTime(startTime);
      if (workoutModel != null) {
        await database.workoutDao.deleteWorkout(workoutModel);
      }
      result = const Right(null);
    } catch (e) {
      result = Left(DatabaseError(
        details: 'Could not remove workout for start time "$startTime".',
        cause: e,
      ));
    }
    return result;
  }
}
