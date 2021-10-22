import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart';
import 'package:workout_diary/src/domain.dart';


class ExercisesDao {
  final Database _database;

  const ExercisesDao(this._database);

  /// Find all [Exercise] summaries - just id and name.
  /// Useful to show list of all exercises.
  Future<List<Exercise>> findAllSummaries(int pageOffset, int pageLimit) async {
    List<Map<String, dynamic>> records = await _database.query(Exercise.table,
        offset: pageOffset, limit: pageLimit);
    return List.generate(records.length, (i) {
      return Exercise(
        id: records[i][Exercise.colId] as int?,
        name: records[i][Exercise.colName] as String,
      );
    });
  }

  /// Find details of [Exercise] with given [id].
  Future<Exercise?> findDetails(int id) async {
    List<Map<String, dynamic>> records = await _database
        .query(Exercise.table, where: '${Exercise.colId} = ?', whereArgs: [id]);
    var exercise;
    if (records.length == 1) {
      var record = records[0];
      exercise = Exercise(
        id: record[Exercise.colId] as int?,
        name: record[Exercise.colName] as String,
        description: record[Exercise.colDescription] as String?,
      );
    }
    return exercise;
  }
}

class WorkoutsDao {
  final Database _database;

  const WorkoutsDao(this._database);

  Future<List<Workout>> findAllSummaries(int pageOffset, int pageLimit) async {
    List<Map<String, dynamic>> records = await _database.query(Workout.table,
        offset: pageOffset, limit: pageLimit);
    return List.generate(records.length, (i) {
      var startTimeMillis = records[i][Workout.colStartTime];
      var endTimeMillis = records[i][Workout.colEndTime];
      return Workout(
          id: records[i][Workout.colId] as int?,
          startTime: startTimeMillis != null
              ? DateTime.fromMillisecondsSinceEpoch(startTimeMillis)
              : null,
          endTime: endTimeMillis != null
              ? DateTime.fromMillisecondsSinceEpoch(endTimeMillis)
              : null,
          title: records[i][Workout.colTitle]);
    });
  }
}

class Repository extends InheritedWidget {
  final ExercisesDao _exercisesDao;

  final WorkoutsDao _workoutDao;

  Repository({Key? key, required Database database, required Widget child})
      : _exercisesDao = ExercisesDao(database),
        _workoutDao = WorkoutsDao(database),
        super(key: key, child: child);

  static Repository of(BuildContext context) {
    final Repository? repository =
        context.dependOnInheritedWidgetOfExactType<Repository>();
    assert(repository != null, 'No $Repository found in context');
    return repository!;
  }

  @override
  bool updateShouldNotify(Repository oldRepository) => false;

  Future<List<Exercise>> finaAllExerciseSummaries(
      int pageOffset, int pageLimit) async {
    return _exercisesDao.findAllSummaries(pageOffset, pageLimit);
  }

  Future<List<Workout>> findAllWorkoutSummaries(
      int pageOffset, int pageLimit) async {
    return _workoutDao.findAllSummaries(pageOffset, pageLimit);
  }
}
