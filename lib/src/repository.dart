import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart';

import 'domain.dart';

class ExercisesDao {
  static const table = 'exercises';

  static const colId = 'id';
  static const colName = 'name';
  static const colDescription = 'description';

  final Database _database;

  const ExercisesDao(this._database);

  /// Find all [Exercise] summaries - just id and name.
  /// Returns list of found [Exercise]s.
  Future<List<Exercise>> findAllSummaries() async {
    List<Map<String, dynamic>> records =
        await _database.query(table, orderBy: colName);
    return List.generate(records.length, (index) {
      return Exercise(
        id: records[index][colId] as int?,
        name: records[index][colName] as String,
      );
    });
  }

  /// Find details of [Exercise] with given [id].
  /// Returns [Exercise] if found otherwise null.
  Future<Exercise?> findDetails(int id) async {
    List<Map<String, dynamic>> records = await _database.query(
      table,
      where: '$colId = ?',
      whereArgs: [id],
    );
    var exercise;
    if (records.length == 1) {
      var record = records.first;
      exercise = Exercise(
        id: record[colId] as int?,
        name: record[colName] as String,
        description: record[colDescription] as String?,
      );
    }
    return exercise;
  }

  /// Insert [Excercise] into repository.
  /// Returns [Excercise] with id.
  Future<Exercise> insert(Exercise exercise) async {
    assert(exercise.id == null);
    var name = exercise.name;
    var description = exercise.description;
    var id = await _database.insert(
      table,
      {
        colName: name,
        colDescription: description,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return Exercise(
      id: id,
      name: name,
      description: description,
    );
  }

  /// Update [Excrcise] in repository.
  /// Returns updated [Exercise] or null it nothing was updated.
  Future<Exercise?> update(Exercise exercise) async {
    var id = exercise.id;
    var name = exercise.name;
    var description = exercise.description;
    var recordsCount = await _database.update(
        table, {colName: name, colDescription: description},
        where: '$colId = ?', whereArgs: [id]);
    return recordsCount == 1
        ? Exercise(id: id, name: name, description: description)
        : null;
  }

  /// Delete [Exercise] with given [id].
  /// Returns count of deleted [Exercise]s.
  Future<int> delete(int id) async {
    return _database.delete(table, where: '$colId = ?', whereArgs: [id]);
  }
}

class WorkoutsDao {
  static const table = 'workouts';

  static const colId = 'id';
  static const colStartTime = 'startTime';
  static const colEndTime = 'endTime';
  static const colTitle = 'title';
  static const colPreComment = 'preComment';
  static const colPostComment = 'postComment';
  final Database _database;

  const WorkoutsDao(this._database);

  Future<List<Workout>> findAllSummaries() async {
    List<Map<String, dynamic>> records = await _database.query(
      table,
      orderBy: '$colId DESC',
    );
    return List.generate(records.length, (i) {
      var startTimeMillis = records[i][colStartTime];
      var endTimeMillis = records[i][colEndTime];
      return Workout(
          id: records[i][colId] as int?,
          startTime: startTimeMillis != null
              ? DateTime.fromMillisecondsSinceEpoch(startTimeMillis)
              : null,
          endTime: endTimeMillis != null
              ? DateTime.fromMillisecondsSinceEpoch(endTimeMillis)
              : null,
          title: records[i][colTitle]);
    });
  }

  Future<Workout> insert(Workout newWorkout) async {
    var title = newWorkout.title;
    var startTime = newWorkout.startTime;
    var endTime = newWorkout.endTime;
    var preComment = newWorkout.preComment;
    var postComment = newWorkout.postComment;

    var id = await _database.insert(
      table,
      {
        colTitle: title,
        colStartTime: startTime?.millisecondsSinceEpoch,
        colEndTime: endTime?.millisecondsSinceEpoch,
        colPreComment: preComment,
        colPostComment: postComment,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return Workout(
        id: id,
        title: title,
        startTime: startTime,
        endTime: endTime,
        preComment: preComment,
        postComment: postComment);
  }

  /// Update [Workout].
  /// Returns updated [Workout] if successful otherwise null.
  Future<Workout?> update(Workout workout) async {
    assert(workout.id != null);
    var id = workout.id;
    var title = workout.title;
    var startTime = workout.startTime;
    var endTime = workout.endTime;
    var preComment = workout.preComment;
    var postComment = workout.postComment;
    var recordsCount = await _database.update(
        table,
        {
          colTitle: title,
          colStartTime: startTime?.millisecondsSinceEpoch,
          colEndTime: endTime?.millisecondsSinceEpoch,
          colPreComment: preComment,
          colPostComment: postComment,
        },
        where: '$colId = ?',
        whereArgs: [id]);
    return recordsCount == 1
        ? Workout(
            id: id,
            title: title,
            startTime: startTime,
            endTime: endTime,
            preComment: preComment,
            postComment: postComment)
        : null;
  }

  /// Delete [Workout] with given [id].
  /// Returns number of deleted [Workout]s.
  Future<int> delete(int id) async {
    return _database.delete(table, where: '$colId = ?', whereArgs: [id]);
  }
}

class WorkoutEntriesDao {
  static const table = 'workout_entries';

  static const colId = 'id';
  static const colExerciseId = 'exercise_id';
  static const colWorkoutId = 'workout_id';
  static const colDetails = 'details';

  final Database _database;

  const WorkoutEntriesDao(this._database);

  Future<int> countByExercise(int exerciseId) async {
    const countAlias = 'entriesCount';
    List<Map<String, Object?>> result = await _database.rawQuery(
        'SELECT count(*) AS \'$countAlias\' FROM $table WHERE $colExerciseId = ?',
        [exerciseId]);
    return result.first[countAlias] as int;
  }

  Future<List<int>> findIdsByWorkoutId(int workoutId) async {
    List<Map<String, dynamic>> records = await _database.query(table, distinct: true, columns: [colId], where: '$colWorkoutId = ?', whereArgs: [workoutId], orderBy: '$colId asc');
    return List.generate(records.length, (index) => records[index][colId]);
  }

  Future<WorkoutEntry> insert(
      {required int workoutId, required WorkoutEntry entry}) async {
    var id = await _database.insert(
      table,
      {
        colExerciseId: entry.exercise.id,
        colWorkoutId: workoutId,
        colDetails: entry.details,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return WorkoutEntry(
      id: id,
      exercise: entry.exercise,
      details: entry.details,
    );
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

  Future<List<Exercise>> findAllExerciseSummaries() {
    return _exercisesDao.findAllSummaries();
  }

  Future<Exercise?> findExerciseDetails(int id) {
    return _exercisesDao.findDetails(id);
  }

  Future<Exercise> insertExercise(Exercise newExercise) {
    return _exercisesDao.insert(newExercise);
  }

  Future<Exercise?> updateExercise(Exercise updatedExercise) {
    return _exercisesDao.update(updatedExercise);
  }

  Future<int> deleteExercise(int id) {
    return _exercisesDao.delete(id);
  }

  Future<List<Workout>> findAllWorkoutSummaries() {
    return _workoutDao.findAllSummaries();
  }

  Future<int> countWorkoutEntriesByExercise(int exerciseId) {
    return _workoutEntriesDao.countByExercise(exerciseId);
  }

  Future<Workout> insertWorkout(Workout workout) async {
    assert(workout.id == null);
    var newWorkout = await _workoutDao.insert(workout);
    assert(newWorkout.id != null);
    var group = FutureGroup();
    workout.entities.forEach((e) => group.add(_workoutEntriesDao.insert(workoutId: newWorkout.id!, entry: e)));
    group.close();
    var newEntities = await group.future;
    newEntities.forEach((e) => newWorkout.addWorkoutEntry(e));
    return newWorkout;
  }

  Future<Workout?> updateWorkout(Workout workout) async {
    assert(workout.id != null);
    var updatedWorkout = await _workoutDao.update(workout);
    if (updatedWorkout != null) {
      var updatedWorkoutId = updatedWorkout.id;
      assert(updatedWorkoutId != null);
      var oldEntityIds = await _workoutEntriesDao.findIdsByWorkoutId(updatedWorkoutId!);
      var newEntities = workout.entities;
      var group = FutureGroup();
      newEntities.forEach((e) {
        if (e.id == null) {
          group.add(_workoutEntriesDao.insert(workoutId: updatedWorkoutId, entry: e));
        } else {
          group.add(_workoutEntriesDao.update(e));
        }
      });
      oldEntityIds.forEach((oldId) {
        if (newEntities.map((e) => e.id).firstWhere((newId) => newId == oldId) == null) {
          group.add(_workoutEntriesDao.delete(oldId));
        }
      });
      group.close();
      var results = await group.future;

    }

    return updatedWorkout;
  }

  Future<int> deleteWorkout(int id) {
    return _workoutDao.delete(id);
  }
}
