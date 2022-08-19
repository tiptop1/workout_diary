import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'exercise.dart';
import 'workout.dart';

class Repository {
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

  late final Database _db;
  static const _dbVersion = 1;
  static const _dbName = 'workout_diary.db';
  static const _sqliteConstraintResultCode = 19;

  Repository._internal();

  Future<Repository> init() async {
    _db = await openDatabase(
      join(await getDatabasesPath(), _dbName),
      onCreate: (db, version) {
        db.execute(
          'CREATE TABLE $_tableExercises($_colExerciseId INTEGER PRIMARY KEY AUTOINCREMENT, $_colExerciseName TEXT NOT NULL, $_colExerciseDescription TEXT)',
        );
        db.execute(
            'CREATE TABLE $_tableExerciseSets($_colExerciseSetId INTEGER PRIMARY KEY AUTOINCREMENT, $_colExerciseSetExerciseId INTEGER NOT NULL, $_colExerciseSetWorkoutId INTEGER NOT NULL, $_colExerciseSetDetails TEXT, FOREIGN KEY ($_colExerciseSetExerciseId) REFERENCES $_tableExercises($_colExerciseId) ON DELETE CASCADE, FOREIGN KEY ($_colExerciseSetWorkoutId) REFERENCES $_tableWorkouts($_colWorkoutId) ON DELETE CASCADE)');
        db.execute(
            'CREATE TABLE $_tableWorkouts($_colWorkoutId INTEGER PRIMARY KEY AUTOINCREMENT, $_colWorkoutStartTime INTEGER, $_colWorkoutEndTime INTEGER, $_colWorkoutTitle TEXT NOT NULL, $_colWorkoutPreComment TEXT, $_colWorkoutPostComment TEXT)');
      },
      version: _dbVersion,
    );
    return Repository._internal();
  }

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
      {
        _colExerciseName: name,
        _colExerciseDescription: description,
      },
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
        _tableExercises,
        {
          _colExerciseName: exercise.name,
          _colExerciseDescription: exercise.description
        },
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
    List<Map<String, Object?>> result = await _db.rawQuery('SELECT count(*) AS \'$countAlias\' FROM $_tableExerciseSets WHERE $_colExerciseSetExerciseId = ?', [exerciseId]);
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
    _db.transaction((txn) async {
       var workoutId = await txn.insert(_tableWorkouts,
        {
          _colWorkoutStartTime: workout.startTime,
          _colWorkoutEndTime: workout.endTime,
          _colWorkoutTitle: workout.title,
          _colWorkoutPreComment: workout.preComment,
          _colWorkoutPostComment: workout.postComment
        },
        conflictAlgorithm: ConflictAlgorithm.rollback,
      );
      _insertExerciseSets(workoutId, exerciseSets, txn);
    }
  }

  Future<Workout> updateWorkout(Workout workout) {
    return database.transaction((txn) => _workoutDao.update(workout, txn));
  }

  Future<int> deleteWorkout(int id) {
    return database.transaction((txn) => _workoutDao.delete(id, txn));
  }

  Future<List<ExerciseSet>> _insertExerciseSets(int workoutId,
      List<ExerciseSet> exerciseSets, Transaction txn) async {
    var batch = txn.batch();
    for (var es in exerciseSets) {
      batch.insert(
          table,
          {
            colExerciseId: es.exercise.id,
            colWorkoutId: workoutId,
            colDetails: es.details,
          },
          conflictAlgorithm: ConflictAlgorithm.rollback);
    }
    var insertResult = await batch.commit();
    if (insertResult is int) {
      throw Exception(
          'Could not insert exercise set because of error code: $insertResult.');
    } else if (insertResult is List<int>) {
      return _toExerciseSet(exerciseSets, insertResult);
    } else {
      throw Exception(
          'Insert result has unknown type: ${insertResult.runtimeType}.');
    }
  }
}
