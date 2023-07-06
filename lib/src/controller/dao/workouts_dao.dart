import 'package:sqflite/sqlite_api.dart';

import '../../model/exercise.dart';
import '../../model/exercise_set.dart';
import '../../model/workout.dart';

class WorkoutsDao {
  // ExerciseSets
  static const tableExerciseSets = 'exercise_sets';
  static const colExerciseSetId = 'id';
  static const colExerciseSetExerciseId = 'exercise_id';
  static const colExerciseSetWorkoutId = 'workout_id';
  static const colExerciseSetDetails = 'details';

  // Workouts
  static const tableWorkouts = 'workouts';
  static const colWorkoutId = 'id';
  static const colWorkoutStartTime = 'startTime';
  static const colWorkoutEndTime = 'endTime';
  static const colWorkoutTitle = 'title';
  static const colWorkoutComment = 'comment';

  late final Database _db;

  WorkoutsDao(Database db) : _db = db;

  Future<List<Workout>> findAllWorkouts(List<Exercise> exercises) async {
    List<Map<String, Object?>> workoutRecords = await _db.query(
      tableWorkouts,
      orderBy: '$colWorkoutId DESC',
    );

    var batch = _db.batch();
    for (var workoutRec in workoutRecords) {
      batch.query(
        tableExerciseSets,
        where: '$colExerciseSetWorkoutId = ?',
        orderBy: '$colExerciseSetId DESC',
        whereArgs: [workoutRec[colWorkoutId]],
      );
    }
    var exerciseSetRecords = <Map<String, Object?>>[];
    var batchResults = await batch.commit();
    for (var i = 0; i < batchResults.length; i++) {
      var exerciseSet = batchResults[i];
      if (exerciseSet is Map<String, Object?>) {
        exerciseSetRecords.add(exerciseSet);
      }
    }
    return _createWorkoutsList(workoutRecords, exerciseSetRecords, exercises);
  }

  Future<Workout> insertWorkout(Workout workout) async {
    assert(workout.id == null,
        'Could not insert already inserted (having id) workout.');
    int? workoutId;
    List<ExerciseSet> exerciseSets = await _db.transaction((txn) async {
      workoutId = await txn.insert(
        tableWorkouts,
        _workoutToMap(workout),
        conflictAlgorithm: ConflictAlgorithm.rollback,
      );
      assert(workoutId != null);
      return _toExerciseSet(workout.exerciseSets,
          await _insertExerciseSets(workoutId!, workout.exerciseSets, txn));
    });
    return workout.copyWith(id: workoutId, exerciseSets: exerciseSets);
  }

  Future<Workout> updateWorkout(Workout workout) async {
    assert(workout.id != null, 'Could not update workout without id.');
    var workoutId = workout.id!;
    var esIdsToDelete = _exerciseSetIdsToDelete(
        await _findExerciseSetIdsByWorkoutId(workoutId),
        workout.exerciseSets.map((e) => e.id).toList(growable: false));
    var esIdsInserted = await _db.transaction((txn) {
      var esInsertBatch = txn.batch();
      var otherBatch = txn.batch();
      _batchUpdateWorkout(workout, otherBatch);
      for (var es in workout.exerciseSets) {
        if (es.id == null) {
          _batchInsertExerciseSets(es, workoutId, esInsertBatch);
        } else {
          _batchUpdateExerciseSets(es, workoutId, otherBatch);
        }
      }
      _batchDeleteExerciseSets(esIdsToDelete, otherBatch);
      otherBatch.commit();
      return esInsertBatch.commit();
    });
    return _toWorkout(
        workout, esIdsInserted.map((e) => e as int).toList(growable: false));
  }

  Future<bool> deleteWorkout(int id) async =>
      await _db
          .delete(tableWorkouts, where: '$colWorkoutId = ?', whereArgs: [id]) ==
      1;

  Future<bool> deleteExerciseSetByExerciseId(int exerciseId) async =>
      await _db.delete(tableExerciseSets,
          where: '$colExerciseSetExerciseId = ?', whereArgs: [exerciseId]) >
      0;

  Future<bool> deleteExerciseSetByWorkoutId(int workoutId) async =>
      await _db.delete(tableExerciseSets,
          where: '$colExerciseSetWorkoutId = ?', whereArgs: [workoutId]) >
      0;

  Future<List<Object?>> _insertExerciseSets(
      int workoutId, List<ExerciseSet> exerciseSets, Transaction txn) async {
    var batch = txn.batch();
    for (var es in exerciseSets) {
      batch.insert(
          tableExerciseSets,
          {
            ..._exerciseSetToMap(es),
            colExerciseSetWorkoutId: workoutId,
          },
          conflictAlgorithm: ConflictAlgorithm.rollback);
    }
    return batch.commit();
  }

  List<ExerciseSet> _toExerciseSet(
      List<ExerciseSet> exerciseSets, List<Object?> insertedIds) {
    assert(exerciseSets.length == insertedIds.length,
        'Exercise set list length (${exerciseSets.length} different than inserted ids list length (${insertedIds.length}).');
    return List.generate(
        exerciseSets.length,
        (i) => ExerciseSet(
              id: insertedIds[i] as int,
              exercise: exerciseSets[i].exercise,
              details: exerciseSets[i].details,
            ));
  }

  Future<List<int>> _findExerciseSetIdsByWorkoutId(int workoutId) async {
    List<Map<String, dynamic>> records = await _db.query(tableExerciseSets,
        distinct: true,
        columns: [colExerciseSetId],
        where: '$colExerciseSetWorkoutId = ?',
        whereArgs: [workoutId],
        orderBy: '$colExerciseSetId asc');
    return List.generate(records.length, (i) => records[i][colExerciseSetId]);
  }

  void _batchUpdateWorkout(Workout workout, Batch batch) {
    batch.update(tableWorkouts, _workoutToMap(workout),
        where: '$colWorkoutId = ?',
        whereArgs: [workout.id],
        conflictAlgorithm: ConflictAlgorithm.rollback);
  }

  Map<String, Object?> _workoutToMap(Workout workout) => {
        colWorkoutStartTime: workout.startTime?.millisecondsSinceEpoch,
        colWorkoutEndTime: workout.endTime?.millisecondsSinceEpoch,
        colWorkoutTitle: workout.title,
        colWorkoutComment: workout.comment,
      };

  Map<String, Object?> _exerciseSetToMap(ExerciseSet exerciseSet) => {
        colExerciseSetExerciseId: exerciseSet.exercise.id,
        colExerciseSetDetails: exerciseSet.details,
      };

  void _batchInsertExerciseSets(
      ExerciseSet exerciseSet, int workoutId, Batch batch) {
    batch.insert(
        tableExerciseSets,
        {
          ..._exerciseSetToMap(exerciseSet),
          colExerciseSetWorkoutId: workoutId,
        },
        conflictAlgorithm: ConflictAlgorithm.rollback);
  }

  void _batchUpdateExerciseSets(
      ExerciseSet exerciseSet, int workoutId, Batch batch) {
    batch.update(
      tableExerciseSets,
      {
        ..._exerciseSetToMap(exerciseSet),
        colExerciseSetWorkoutId: workoutId,
      },
      where: '$colExerciseSetId = ?',
      whereArgs: [exerciseSet.id!],
      conflictAlgorithm: ConflictAlgorithm.rollback,
    );
  }

  void _batchDeleteExerciseSets(List<int> exerciseSetIds, Batch batch) {
    batch.delete(tableExerciseSets,
        where:
            '$colExerciseSetId in (${exerciseSetIds.map((e) => "?").join(",")})',
        whereArgs: exerciseSetIds);
  }

  Workout _toWorkout(Workout workout, List<int> insertedExerciseSetIds) {
    var currEsList = workout.exerciseSets;
    var insertedEsIndex = 0;
    var newEsList = List.generate(currEsList.length, (i) {
      var currEs = currEsList[i];
      return ExerciseSet(
          id: currEs.id ?? insertedExerciseSetIds[insertedEsIndex++],
          exercise: currEs.exercise,
          details: currEs.details);
    });
    return Workout(
      id: workout.id,
      startTime: workout.startTime,
      endTime: workout.endTime,
      title: workout.title,
      comment: workout.comment,
      exerciseSets: newEsList,
    );
  }

  List<Workout> _createWorkoutsList(List<Map<String, Object?>> workoutRecords,
      List<Map<String, Object?>> exerciseSetRecords, List<Exercise> exercises) {
    var workouts = <Workout>[];
    for (var workoutRecord in workoutRecords) {
      workouts.add(_createWorkout(
          workoutRecord,
          exerciseSetRecords.where((exerciseSetRecord) =>
              exerciseSetRecord[colExerciseSetWorkoutId] ==
              workoutRecord[colWorkoutId]),
          exercises));
    }
    return workouts;
  }

  Workout _createWorkout(
      Map<String, Object?> workoutRecord,
      Iterable<Map<String, Object?>> exerciseSetRecords,
      List<Exercise> exercises) {
    var startTime = workoutRecord[colWorkoutStartTime] as int?;
    var endTime = workoutRecord[colWorkoutEndTime] as int?;
    return Workout(
      title: workoutRecord[colWorkoutTitle] as String,
      id: workoutRecord[colWorkoutId] as int?,
      startTime: startTime != null
          ? DateTime.fromMillisecondsSinceEpoch(startTime)
          : null,
      endTime:
          endTime != null ? DateTime.fromMillisecondsSinceEpoch(endTime) : null,
      comment: workoutRecord[colWorkoutComment] as String?,
      exerciseSets: _createExerciseSetList(exerciseSetRecords, exercises),
    );
  }

  List<ExerciseSet> _createExerciseSetList(
      Iterable<Map<String, Object?>> exerciseSetRecords,
      List<Exercise> exercises) {
    var exerciseSet = <ExerciseSet>[];
    var exercisesMapping = <int?, Exercise>{for (var e in exercises) e.id: e};

    for (var exerciseSetRecord in exerciseSetRecords) {
      var exerciseId = exerciseSetRecord[colExerciseSetExerciseId];
      var exerciseSetDetails =
          exerciseSetRecord[colExerciseSetDetails] as String?;
      if (exerciseId != null && exercisesMapping.containsKey(exerciseId)) {
        exerciseSet.add(ExerciseSet(
          exercise: exercisesMapping[exerciseId]!,
          details: exerciseSetDetails,
        ));
      }
    }
    return exerciseSet;
  }

  List<int> _exerciseSetIdsToDelete(List<int> dbEsIds, List<int?> esIds) {
    var idsToDelete = <int>[];
    for (var dbEsId in dbEsIds) {
      if (!esIds.contains(dbEsId)) {
        idsToDelete.add(dbEsId);
      }
    }
    return idsToDelete;
  }
}
