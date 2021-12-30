import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart';

import 'domain.dart';

class ExercisesDao {
  final Database _database;

  const ExercisesDao(this._database);

  /// Find all [Exercise] summaries - just id and name.
  /// Useful to show list of all exercises.
  Future<List<Exercise>> findAllSummaries() async {
    List<Map<String, dynamic>> records = await _database.query(Exercise.table, orderBy: Exercise.colName);
    return List.generate(records.length, (i) {
      return Exercise(
        id: records[i][Exercise.colId] as int?,
        name: records[i][Exercise.colName] as String,
      );
    });
  }

  /// Find details of [Exercise] with given [id].
  Future<Exercise?> findDetails(int id) async {
    List<Map<String, dynamic>> records = await _database.query(
      Exercise.table,
      where: '${Exercise.colId} = ?',
      whereArgs: [id],
    );
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

  Future<Exercise> insert(Exercise exercise) async {
    var name = exercise.name;
    var description = exercise.description;
    var id = await _database.insert(
      Exercise.table,
      {
        Exercise.colName: name,
        Exercise.colDescription: description,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return Exercise(
      id: id,
      name: name,
      description: description,
    );
  }

  Future<Exercise?> update(Exercise exercise) async {
    var id = exercise.id;
    var name = exercise.name;
    var description = exercise.description;
    var recordsCount = await _database.update(Exercise.table,
        {Exercise.colName: name, Exercise.colDescription: description},
        where: '${Exercise.colId} = ?', whereArgs: [id]);
    var updatedExercise;
    if (recordsCount == 1) {
      updatedExercise = Exercise(id: id, name: name, description: description);
    }
    return updatedExercise;
  }

  Future<int> delete(int exerciseId) async {
    return _database.delete(Exercise.table,
        where: '${Exercise.colId} = ?', whereArgs: [exerciseId]);
  }
}

class WorkoutsDao {
  final Database _database;

  const WorkoutsDao(this._database);

  Future<List<Workout>> findAllSummaries() async {
    List<Map<String, dynamic>> records = await _database.query(
      Workout.table,
      orderBy: '${Workout.colId} DESC',
    );
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

class WorkoutEntriesDao {
  final Database _database;

  const WorkoutEntriesDao(this._database);

  Future<int> countByExercise(int exerciseId) async {
    const countAlias = 'entriesCount';
    List<Map<String, Object?>> result = await _database.rawQuery(
        'SELECT count(*) AS \'$countAlias\' FROM ${WorkoutEntry.table} WHERE ${WorkoutEntry.colExerciseId} = ?',
        [exerciseId]);
    return result.first[countAlias] as int;
  }
}

class Repository extends InheritedWidget {
  final ExercisesDao _exercisesDao;

  final WorkoutsDao _workoutDao;

  final WorkoutEntriesDao _workoutEntriesDao;

  final Database database;

  Repository({Key? key, required Database database, required Widget child})
      : database = database,
        _exercisesDao = ExercisesDao(database),
        _workoutDao = WorkoutsDao(database),
        _workoutEntriesDao = WorkoutEntriesDao(database),
        super(key: key, child: child);

  static Repository of(BuildContext context) {
    final Repository? repository =
        context.dependOnInheritedWidgetOfExactType<Repository>();
    assert(repository != null, 'No $Repository found in context!');
    return repository!;
  }

  @override
  bool updateShouldNotify(Repository oldRepository) => false;

  Future<List<Exercise>> finaAllExerciseSummaries() async {
    return _exercisesDao.findAllSummaries();
  }

  Future<List<Workout>> findAllWorkoutSummaries() async {
    return _workoutDao.findAllSummaries();
  }

  Future<Exercise?> findExerciseDetails(int id) async {
    return _exercisesDao.findDetails(id);
  }

  Future<Exercise> insertExercise(Exercise newExercise) async {
    return _exercisesDao.insert(newExercise);
  }

  Future<Exercise?> updateExercise(Exercise updatedExercise) async {
    return _exercisesDao.update(updatedExercise);
  }

  Future<int> deleteExercise(int id) async {
    return _exercisesDao.delete(id);
  }

  Future<int> countWorkoutExercisesByExercise(int exerciseId) {
    return _workoutEntriesDao.countByExercise(exerciseId);
  }
}
