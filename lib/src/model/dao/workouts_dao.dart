import 'package:sqflite/sqlite_api.dart';

import '../exercise.dart';
import '../exercise_set.dart';
import '../workout.dart';

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
  static const colWorkoutPreComment = 'preComment';
  static const colWorkoutPostComment = 'postComment';

  late final Database _db;

  WorkoutsDao(Database db) : _db = db;

  Future<List<Workout>> findAll(List<Exercise> exercises) async {
    List<Map<String, Object?>> workoutRecords = await _db.query(
      tableWorkouts,
      orderBy: '$colWorkoutId DESC',
    );

    var batch = _db.batch();
    workoutRecords.forEach((workoutRecord) => batch.query(tableExerciseSets,
        where: '$colExerciseSetWorkoutId = ?',
        orderBy: '$colExerciseSetId DESC',
        whereArgs: [workoutRecord[colWorkoutId]]));
    List<Map<String, Object?>> exerciseSetRecords =
        await batch.commit() as List<Map<String, Object?>>;

    return _createWorkoutsList(workoutRecords, exerciseSetRecords, exercises);
  }

  Future<Workout> insertWorkout(Workout workout) async {
    assert(workout.id == null,
        'Could not insert already inserted (having id) workout.');
    var workoutId;
    List<ExerciseSet> exerciseSets = await _db.transaction((txn) async {
      workoutId = await txn.insert(
        tableWorkouts,
        _workoutToMap(workout),
        conflictAlgorithm: ConflictAlgorithm.rollback,
      );
      return _toExerciseSet(workout.exerciseSets,
          await _insertExerciseSets(workoutId, workout.exerciseSets, txn));
    });
    return workout.copyWith(id: workoutId, exerciseSets: exerciseSets);
  }

  Future<Workout> updateWorkout(Workout workout) async {
    assert(workout.id != null, 'Could not update workout without id.');
    var insertedExerciseSets = <int, ExerciseSet>{};
    var exerciseSetIdsToDelete =
        await _findExerciseSetIdsByWorkoutId(workout.id!);
    var results = await _db.transaction((txn) async {
      var batch = txn.batch();
      _updateWorkoutInBatch(workout, batch);
      var i = 0;
      for (var es in workout.exerciseSets) {
        if (es.id == null) {
          insertedExerciseSets[i++] = es;
          _insertExerciseSetInBatch(es, workout.id!, batch);
        } else {
          _updateExerciseSetInBatch(es, workout.id!, batch);
        }
      }
      _deleteExerciseSetsInBatch(exerciseSetIdsToDelete, batch);
      batch.commit();
    });
    return _toWorkout(workout, insertedExerciseSets, results);
  }

  Future<bool> deleteWorkout(int id) async =>
      await _db.delete(tableWorkouts, where: '$colWorkoutId = ?', whereArgs: [id]) == 1;

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

  void _updateWorkoutInBatch(Workout workout, Batch batch) {
    batch.update(tableWorkouts, _workoutToMap(workout),
        where: '$colWorkoutId = ?',
        whereArgs: [workout.id],
        conflictAlgorithm: ConflictAlgorithm.rollback);
  }

  Map<String, Object?> _workoutToMap(Workout workout) => {
        colWorkoutStartTime: workout.startTime?.millisecondsSinceEpoch,
        colWorkoutEndTime: workout.endTime?.millisecondsSinceEpoch,
        colWorkoutTitle: workout.title,
        colWorkoutPreComment: workout.preComment,
        colWorkoutPostComment: workout.postComment,
      };

  Map<String, Object?> _exerciseSetToMap(ExerciseSet exerciseSet) => {
        colExerciseSetExerciseId: exerciseSet.exercise.id,
        colExerciseSetDetails: exerciseSet.details,
      };

  void _insertExerciseSetInBatch(
      ExerciseSet exerciseSet, int workoutId, Batch batch) {
    batch.insert(
        tableExerciseSets,
        {
          ..._exerciseSetToMap(exerciseSet),
          colExerciseSetWorkoutId: workoutId,
        },
        conflictAlgorithm: ConflictAlgorithm.rollback);
  }

  void _updateExerciseSetInBatch(
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

  void _deleteExerciseSetsInBatch(List<int> exerciseSetIds, Batch batch) {
    batch.delete(tableExerciseSets,
        where:
            '$colExerciseSetId in (${exerciseSetIds.map((e) => "?").join(",")})',
        whereArgs: exerciseSetIds);
  }

  Workout _toWorkout(Workout workout,
      Map<int, ExerciseSet> insertedExerciseSets, List<int> results) {
    var exerciseSets = List.generate(workout.exerciseSets.length, (i) {
      var es = workout.exerciseSets[i];
      if (es.id == null) {
        es = ExerciseSet(
            id: results[i + 1], exercise: es.exercise, details: es.details);
      }
      return es;
    });
    return Workout(
      id: workout.id,
      startTime: workout.startTime,
      endTime: workout.endTime,
      title: workout.title,
      preComment: workout.preComment,
      postComment: workout.postComment,
      exerciseSets: exerciseSets,
    );
  }

  List<Workout> _createWorkoutsList(List<Map<String, Object?>> workoutRecords,
      List<Map<String, Object?>> exerciseSetRecords, List<Exercise> exercises) {
    var workouts = <Workout>[];
    workoutRecords.forEach((workoutRecord) => workouts.add(_createWorkout(
        workoutRecord,
        exerciseSetRecords.where((exerciseSetRecord) =>
            exerciseSetRecord[colExerciseSetWorkoutId] ==
            workoutRecord[colWorkoutId]),
        exercises)));
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
      id: workoutRecord[colWorkoutId] as int,
      startTime: startTime != null
          ? DateTime.fromMillisecondsSinceEpoch(startTime)
          : null,
      endTime:
          endTime != null ? DateTime.fromMillisecondsSinceEpoch(endTime) : null,
      preComment: workoutRecord[colWorkoutPreComment] as String,
      postComment: workoutRecord[colWorkoutPostComment] as String,
      exerciseSets: _createExerciseSetList(exerciseSetRecords, exercises),
    );
  }

  List<ExerciseSet> _createExerciseSetList(
      Iterable<Map<String, Object?>> exerciseSetRecords,
      List<Exercise> exercises) {
    var exerciseSet = <ExerciseSet>[];
    var exercisesMapping =
        Map.fromIterable(exercises, key: (e) => e.id, value: (e) => e);
    exerciseSetRecords
        .forEach((exerciseSetRecord) => exerciseSet.add(ExerciseSet(
              exercise:
                  exercisesMapping[exerciseSetRecord[colExerciseSetExerciseId]],
              details: exerciseSetRecord[colExerciseSetDetails] as String?,
            )));
    return exerciseSet;
  }
}
