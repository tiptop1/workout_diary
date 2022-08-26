import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'exercise.dart';
import 'exercise_set.dart';
import 'workout.dart';

class Repository {
  static const _defaultDbName = 'workout_diary.db';
  static const _defaultDbVersion = 1;

  // Exercises
  static const _tableExercises = 'exercises';
  static const _colExerciseId = 'ex_id';
  static const _colExerciseName = 'ex_name';
  static const _colExerciseDescription = 'ex_description';

  // ExerciseSets
  static const _tableExerciseSets = 'exercise_sets';
  static const _colExerciseSetId = 'es_id';
  static const _colExerciseSetExerciseId = 'es_exercise_id';
  static const _colExerciseSetWorkoutId = 'es_workout_id';
  static const _colExerciseSetDetails = 'es_details';

  // Workouts
  static const _tableWorkouts = 'workouts';
  static const _colWorkoutId = 'wr_id';
  static const _colWorkoutStartTime = 'wr_startTime';
  static const _colWorkoutEndTime = 'wr_endTime';
  static const _colWorkoutTitle = 'wr_title';
  static const _colWorkoutPreComment = 'wr_preComment';
  static const _colWorkoutPostComment = 'wr_postComment';

  static late final Database _db;
  static const _sqliteConstraintResultCode = 19;

  Repository._internal();

  static Future<Repository> init({String? dbPath, int? dbVersion}) async {
    _db = await openDatabase(
      dbPath ?? join(await getDatabasesPath(), _defaultDbName),
      version: dbVersion ?? _defaultDbVersion,
      onCreate: (db, version) {
        db.execute(
          'CREATE TABLE $_tableExercises($_colExerciseId INTEGER PRIMARY KEY AUTOINCREMENT, $_colExerciseName TEXT NOT NULL, $_colExerciseDescription TEXT)',
        );
        db.execute(
            'CREATE TABLE $_tableExerciseSets($_colExerciseSetId INTEGER PRIMARY KEY AUTOINCREMENT, $_colExerciseSetExerciseId INTEGER NOT NULL, $_colExerciseSetWorkoutId INTEGER NOT NULL, $_colExerciseSetDetails TEXT, FOREIGN KEY ($_colExerciseSetExerciseId) REFERENCES $_tableExercises($_colExerciseId) ON DELETE CASCADE, FOREIGN KEY ($_colExerciseSetWorkoutId) REFERENCES $_tableWorkouts($_colWorkoutId) ON DELETE CASCADE)');
        db.execute(
            'CREATE TABLE $_tableWorkouts($_colWorkoutId INTEGER PRIMARY KEY AUTOINCREMENT, $_colWorkoutStartTime INTEGER, $_colWorkoutEndTime INTEGER, $_colWorkoutTitle TEXT NOT NULL, $_colWorkoutPreComment TEXT, $_colWorkoutPostComment TEXT)');
      },
    );

    return Repository._internal();
  }

  void dispose() => _db.close();

  Future<List<Exercise>> findAllExerciseSummaries() async {
    List<Map<String, dynamic>> records =
        await _db.query(_tableExercises, orderBy: _colExerciseName);
    return List.generate(records.length, (index) {
      return Exercise(
        id: records[index][_colExerciseId] as int,
        name: records[index][_colExerciseName] as String,
      );
    });
  }

  Future<Exercise?> findExerciseDetails(int id) async {
    List<Map<String, dynamic>> records = await _db.query(
      _tableExercises,
      where: '$_colExerciseId = ?',
      whereArgs: [id],
    );
    var exercise;
    if (records.length == 1) {
      var record = records.first;
      exercise = Exercise(
        id: record[_colExerciseId] as int,
        name: record[_colExerciseName] as String,
        description: record[_colExerciseDescription] as String?,
      );
    }
    return exercise;
  }

  Future<Exercise> insertExercise(Exercise exercise) async {
    assert(exercise.id == null);
    var name = exercise.name;
    var description = exercise.description;
    var id = await _db.insert(
      _tableExercises,
      _exerciseToMap(exercise),
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
    if (id == _sqliteConstraintResultCode) {
      throw Exception('Result code: $id. Could not insert exercise $exercise.');
    } else {
      return Exercise(
        id: id,
        name: name,
        description: description,
      );
    }
  }

  Future<Exercise?> updateExercise(Exercise exercise) async {
    var affectedRowsCount = await _db.update(
        _tableExercises, _exerciseToMap(exercise),
        where: '$_colExerciseId = ?',
        whereArgs: [exercise.id],
        conflictAlgorithm: ConflictAlgorithm.fail);
    var updatedExercise;
    if (affectedRowsCount > 1) {
      if (affectedRowsCount == _sqliteConstraintResultCode) {
        throw Exception(
            'Result code: $affectedRowsCount. Could not update exercise $exercise.');
      } else {
        updatedExercise = exercise;
      }
    }
    return updatedExercise;
  }

  Future<int> deleteExercise(int id) {
    return _db
        .delete(_tableExercises, where: '$_colExerciseId = ?', whereArgs: [id]);
  }

  Future<List<Workout>> findAllWorkoutSummaries() async {
    List<Map<String, dynamic>> records = await _db.query(
      _tableWorkouts,
      orderBy: '$_colWorkoutId DESC',
    );
    return List.generate(records.length, (i) {
      var startTimeMillis = records[i][_colWorkoutStartTime];
      var endTimeMillis = records[i][_colWorkoutEndTime];
      return Workout(
          id: records[i][_colWorkoutId] as int?,
          startTime: startTimeMillis != null
              ? DateTime.fromMillisecondsSinceEpoch(startTimeMillis)
              : null,
          endTime: endTimeMillis != null
              ? DateTime.fromMillisecondsSinceEpoch(endTimeMillis)
              : null,
          title: records[i][_colWorkoutTitle]);
    });
  }

  Future<int> countExerciseSets(int exerciseId) async {
    const countAlias = 'entriesCount';
    List<Map<String, Object?>> result = await _db.rawQuery(
        'SELECT count(*) AS \'$countAlias\' FROM $_tableExerciseSets WHERE $_colExerciseSetExerciseId = ?',
        [exerciseId]);
    int count = 0;
    if (result.length > 0) {
      var firstResult = result.first;
      if (firstResult.containsKey(countAlias)) {
        count = firstResult[countAlias] as int;
      }
    }
    return count;
  }

  Future<Workout> insertWorkout(Workout workout) async {
    assert(workout.id == null,
        'Could not insert already inserted (having id) workout.');
    var workoutId;
    List<ExerciseSet> exerciseSets = await _db.transaction((txn) async {
      workoutId = await txn.insert(
        _tableWorkouts,
        _workoutToMap(workout),
        conflictAlgorithm: ConflictAlgorithm.rollback,
      );
      if (workoutId == _sqliteConstraintResultCode) {
        throw Exception(
            'Result code: $workoutId. Could not insert workout $workout.');
      }
      return await _insertExerciseSets(workoutId, workout.exerciseSets, txn);
    });
    return Workout(
      id: workoutId,
      startTime: workout.startTime,
      endTime: workout.endTime,
      title: workout.title,
      preComment: workout.preComment,
      postComment: workout.postComment,
      exerciseSets: exerciseSets,
    );
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

  Future<int> deleteWorkout(int id) async =>
      _db.delete(_tableWorkouts, where: '$_colWorkoutId = ?', whereArgs: [id]);

  Future<List<ExerciseSet>> _insertExerciseSets(
      int workoutId, List<ExerciseSet> exerciseSets, Transaction txn) async {
    var batch = txn.batch();
    for (var es in exerciseSets) {
      batch.insert(
          _tableExerciseSets,
          {
            ..._exerciseSetToMap(es),
            _colExerciseSetWorkoutId: workoutId,
          },
          conflictAlgorithm: ConflictAlgorithm.rollback);
    }
    var insertResult = await batch.commit();
    if (insertResult is int) {
      throw Exception(
          'Result code: $insertResult. Could not insert exercise sets.');
    } else if (insertResult is List<int>) {
      return _toExerciseSet(exerciseSets, insertResult);
    } else {
      throw Exception(
          'Insert result has unknown type: ${insertResult.runtimeType}.');
    }
  }

  List<ExerciseSet> _toExerciseSet(
      List<ExerciseSet> exerciseSets, List<int> insertedIds) {
    assert(exerciseSets.length == insertedIds.length,
        'Exercise set list length (${exerciseSets.length} different than inserted ids list length (${insertedIds.length}).');
    return List.generate(
        exerciseSets.length,
        (i) => ExerciseSet(
              id: insertedIds[i],
              exercise: exerciseSets[i].exercise,
              details: exerciseSets[i].details,
            ));
  }

  Future<List<int>> _findExerciseSetIdsByWorkoutId(int workoutId) async {
    List<Map<String, dynamic>> records = await _db.query(_tableExerciseSets,
        distinct: true,
        columns: [_colExerciseSetId],
        where: '$_colExerciseSetWorkoutId = ?',
        whereArgs: [workoutId],
        orderBy: '$_colExerciseSetId asc');
    return List.generate(
        records.length, (index) => records[index][_colExerciseSetId]);
  }

  void _updateWorkoutInBatch(Workout workout, Batch batch) {
    batch.update(_tableWorkouts, _workoutToMap(workout),
        where: '$_colWorkoutId = ?',
        whereArgs: [workout.id],
        conflictAlgorithm: ConflictAlgorithm.rollback);
  }

  Map<String, Object?> _exerciseToMap(Exercise exercise) => {
        _colExerciseName: exercise.name,
        _colExerciseDescription: exercise.description,
      };

  Map<String, Object?> _workoutToMap(Workout workout) => {
        _colWorkoutStartTime: workout.startTime,
        _colWorkoutEndTime: workout.endTime,
        _colWorkoutTitle: workout.title,
        _colWorkoutPreComment: workout.preComment,
        _colWorkoutPostComment: workout.postComment,
      };

  Map<String, Object?> _exerciseSetToMap(ExerciseSet exerciseSet) => {
        _colExerciseSetExerciseId: exerciseSet.exercise.id,
        _colExerciseSetDetails: exerciseSet.details,
      };

  void _insertExerciseSetInBatch(
      ExerciseSet exerciseSet, int workoutId, Batch batch) {
    batch.insert(
        _tableExerciseSets,
        {
          ..._exerciseSetToMap(exerciseSet),
          _colExerciseSetWorkoutId: workoutId,
        },
        conflictAlgorithm: ConflictAlgorithm.rollback);
  }

  void _updateExerciseSetInBatch(
      ExerciseSet exerciseSet, int workoutId, Batch batch) {
    batch.update(
      _tableExerciseSets,
      {
        ..._exerciseSetToMap(exerciseSet),
        _colExerciseSetWorkoutId: workoutId,
      },
      where: '$_colExerciseSetId = ?',
      whereArgs: [exerciseSet.id!],
      conflictAlgorithm: ConflictAlgorithm.rollback,
    );
  }

  void _deleteExerciseSetsInBatch(List<int> exerciseSetIds, Batch batch) {
    batch.delete(_tableExerciseSets,
        where:
            '$_colExerciseSetId in (${exerciseSetIds.map((e) => "?").join(",")})',
        whereArgs: exerciseSetIds);
  }

  Workout _toWorkout(Workout workout,
      Map<int, ExerciseSet> insertedExerciseSets, List<int> results) {
    if (results.firstWhere((e) => e == _sqliteConstraintResultCode,
            orElse: () => -1) <
        0) {
      throw Exception('Could not update workout $workout.');
    }
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
}
