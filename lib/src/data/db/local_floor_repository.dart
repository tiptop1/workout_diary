import 'package:fpdart/fpdart.dart';
import 'package:workout_diary/src/domain/entity/exercise_set.dart';
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
  int? exerciseMaxId;
  int? workoutMaxId;
  int? exerciseSetMaxId;

  LocalFloorRepository(this.database);

  @override
  Future<Either<Failure, void>> addExercise(Exercise exercise) async {
    Either<Failure, void> result;
    try {
      var exerciseModel = _toExerciseModel(exercise);
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
      var id = workout.id.id;
      var workoutModel = _toWorkoutModel(workout);
      await database.workoutDao.insertWorkout(workoutModel);

      for (var exerciseSet in workout.exerciseSets) {
        var model = _toExerciseSetModel(id, exerciseSet);
        database.exerciseSetDao.insertExerciseSet(model);
      }
      result = const Right(null);
    } catch (e) {
      result = Left(DatabaseError(
        details: 'Could not add workout $workout.',
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
                id: ExerciseId(e.id),
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
                id: WorkoutId(workoutModel.id),
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
  Future<Either<Failure, Exercise>> getExercise(ExerciseId exerciseId) async {
    Either<Failure, Exercise> result;
    try {
      var exerciseModel =
          await database.exerciseDao.findExerciseById(exerciseId.id);
      if (exerciseModel != null) {
        var exercise = Exercise(
          id: exerciseId,
          name: exerciseModel.name,
          description: exerciseModel.description,
        );
        result = Right(exercise);
      } else {
        result =
            Left(DatabaseError(details: 'No exercise with id $exerciseId.'));
      }
    } catch (e) {
      result = Left(DatabaseError(
        details: 'Could not get exercise with id $exerciseId.',
        cause: e,
      ));
    }
    return result;
  }

  @override
  Future<Either<Failure, Workout>> getWorkout(WorkoutId workoutId) async {
    Either<Failure, Workout> result;
    try {
      var workoutModel =
          await database.workoutDao.findWorkoutById(workoutId.id);
      if (workoutModel != null) {
        var workout = Workout(
          id: workoutId,
          title: workoutModel.title,
          startTime: workoutModel.startTime,
          endTime: workoutModel.endTime,
          comment: workoutModel.comment,
          exerciseSets: await _getExerciseSets(workoutId.id),
        );
        result = Right(workout);
      } else {
        result = Left(DatabaseError(
          details: 'No workout for id $workoutId".',
        ));
      }
    } catch (e) {
      result = Left(DatabaseError(
        details: 'Could not get workout with id $workoutId.',
        cause: e,
      ));
    }
    return result;
  }

  @override
  Future<Either<Failure, void>> modifyExercise(Exercise exercise) async {
    Either<Failure, void> result;
    try {
      var exerciseModel = _toExerciseModel(exercise);
      await database.exerciseDao.updateExercise(exerciseModel);
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
  Future<Either<Failure, void>> modifyWorkout(Workout workout) async {
    Either<Failure, void> result;
    try {
      var id = workout.id.id;
      var workoutModel = await database.workoutDao.findWorkoutById(id);
      if (workoutModel != null) {
        if (workoutModel.title != workout.title ||
            workoutModel.startTime != workout.startTime ||
            workoutModel.endTime != workout.endTime ||
            workoutModel.comment != workout.comment) {
          await database.workoutDao.updateWorkout(_toWorkoutModel(workout));
        }
        result = await _modifyExerciseSets(id, workout.exerciseSets);
      } else {
        result = Left(DatabaseError(
            details: 'Could not find workout $workout for modification.'));
      }
    } catch (e) {
      result = Left(DatabaseError(
        details: 'Could not modify workout $workout.',
        cause: e,
      ));
    }
    return result;
  }

  @override
  Future<Either<Failure, void>> removeExercise(Exercise exercise) async {
    Either<Failure, void> result;
    try {
      await database.exerciseDao.deleteExercise(_toExerciseModel(exercise));
      result = const Right(null);
    } catch (e) {
      result = Left(DatabaseError(
        details: 'Could not remove exercise $exercise.',
        cause: e,
      ));
    }
    return result;
  }

  @override
  Future<Either<Failure, void>> removeWorkout(Workout workout) async {
    Either<Failure, void> result;
    try {
      await database.workoutDao.deleteWorkout(_toWorkoutModel(workout));
      result = const Right(null);
    } catch (e) {
      result = Left(DatabaseError(
        details: 'Could not remove workout $workout.',
        cause: e,
      ));
    }
    return result;
  }

  @override
  Future<Either<Failure, ExerciseId>> nextExerciseId() async {
    Either<Failure, ExerciseId> result;
    try {
      exerciseMaxId ??= await database.exerciseDao.maxId();
      exerciseMaxId = (exerciseMaxId != null ? exerciseMaxId! + 1 : 1);
      result = Right(ExerciseId(exerciseMaxId!));
    } catch (e) {
      result = Left(DatabaseError(
        details: 'Could not get next id for exercises.',
        cause: e,
      ));
    }
    return result;
  }

  @override
  Future<Either<Failure, WorkoutId>> nextWorkoutId() async {
    Either<Failure, WorkoutId> result;
    try {
      workoutMaxId ??= await database.workoutDao.maxId();
      workoutMaxId = (workoutMaxId != null ? workoutMaxId! + 1 : 1);
      result = Right(WorkoutId(workoutMaxId!));
    } catch (e) {
      result = Left(DatabaseError(
        details: 'Could not get next id for workouts.',
        cause: e,
      ));
    }
    return result;
  }

  @override
  Future<Either<Failure, ExerciseSetId>> nextExerciseSetId() async {
    Either<Failure, ExerciseSetId> result;
    try {
      exerciseSetMaxId ??= await database.exerciseSetDao.maxId();
      exerciseSetMaxId = (exerciseSetMaxId != null ? exerciseSetMaxId! + 1 : 1);
      result = Right(ExerciseSetId(exerciseSetMaxId!));
    } catch (e) {
      result = Left(DatabaseError(
        details: 'Could not get next id for exercise sets.',
        cause: e,
      ));
    }
    return result;
  }

  Future<Either<Failure, void>> _modifyExerciseSets(
      int workoutId, List<ExerciseSet> exerciseSets) async {
    Either<Failure, void> result;
    try {
      var currEsModels = <int, ExerciseSetModel>{};
      for (var esModel in await database.exerciseSetDao
          .findExerciseSetsByWorkoutId(workoutId)) {
        currEsModels[esModel.id] = esModel;
      }

      var newEsModels = <int, ExerciseSetModel>{};
      for (var es in exerciseSets) {
        var newEsModel = _toExerciseSetModel(workoutId, es);
        newEsModels[newEsModel.id] = newEsModel;
        if (currEsModels.containsKey(es.id.id)) {
          var currEsModel = currEsModels[es.id.id]!;
          if (newEsModel.exerciseId != currEsModel.exerciseId ||
              newEsModel.workoutId != currEsModel.workoutId ||
              newEsModel.details != currEsModel.details ||
              newEsModel.orderNumber != currEsModel.orderNumber) {
            database.exerciseSetDao.updateExerciseSet(newEsModel);
          } else {
            database.exerciseSetDao.insertExerciseSet(newEsModel);
          }
        }
      }
      for (var currEsId in currEsModels.keys) {
        if (!newEsModels.containsKey(currEsId)) {
          database.exerciseSetDao.deleteExerciseSet(currEsModels[currEsId]!);
        }
      }
      result = const Right(null);
    } catch (e) {
      result = Left(
          DatabaseError(details: 'Could not modify exerciseSets.', cause: e));
    }
    return result;
  }

  ExerciseModel _toExerciseModel(Exercise exercise) {
    return ExerciseModel(
      id: exercise.id.id,
      name: exercise.name,
      description: exercise.description,
    );
  }

  WorkoutModel _toWorkoutModel(Workout workout) {
    return WorkoutModel(
      id: workout.id.id,
      title: workout.title,
      startTime: workout.startTime,
      endTime: workout.endTime,
      comment: workout.comment,
    );
  }

  ExerciseSetModel _toExerciseSetModel(int workoutId, ExerciseSet exerciseSet) {
    return ExerciseSetModel(
      id: exerciseSet.id.id,
      exerciseId: exerciseSet.exercise.id.id,
      workoutId: workoutId,
      details: exerciseSet.details,
      orderNumber: exerciseSet.orderNumber,
    );
  }

  Future<List<ExerciseSet>> _getExerciseSets(int workoutId) async {
    var exerciseSets = [];
    for (var esModel in await database.exerciseSetDao
        .findExerciseSetsByWorkoutId(workoutId)) {
      exerciseSets.add(ExerciseSet(
        id: ExerciseSetId(esModel.id),
        exercise: await _getExercise(esModel.exerciseId),
        details: esModel.details,
        orderNumber: esModel.orderNumber,
      ));
    }
    return List.unmodifiable(exerciseSets);
  }

  Future<Exercise> _getExercise(int exerciseId) async {
    var exerciseModel = await database.exerciseDao.findExerciseById(exerciseId);
    if (exerciseModel != null) {
      return Exercise(
        id: ExerciseId(exerciseModel.id),
        name: exerciseModel.name,
        description: exerciseModel.description,
      );
    } else {
      throw DatabaseError(
          details: 'Could not find exercise with id $exerciseId.');
    }
  }
}
