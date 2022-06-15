import 'dart:async';

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
  /// Useful to show list of all exercises.
  Future<List<Exercise>> findAllSummaries() async {
    List<Map<String, dynamic>> records =
        await _database.query(table, orderBy: colName);
    return List.generate(records.length, (i) {
      return Exercise(
        id: records[i][colId] as int?,
        name: records[i][colName] as String,
      );
    });
  }

  /// Find details of [Exercise] with given [id].
  Future<Exercise?> findDetails(int id) async {
    List<Map<String, dynamic>> records = await _database.query(
      table,
      where: '$colId = ?',
      whereArgs: [id],
    );
    var exercise;
    if (records.length == 1) {
      var record = records[0];
      exercise = Exercise(
        id: record[colId] as int?,
        name: record[colName] as String,
        description: record[colDescription] as String?,
      );
    }
    return exercise;
  }

  Future<Exercise> insert(Exercise exercise) async {
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

  Future<Exercise?> update(Exercise exercise) async {
    var id = exercise.id;
    var name = exercise.name;
    var description = exercise.description;
    var recordsCount = await _database.update(
        table, {colName: name, colDescription: description},
        where: '$colId = ?', whereArgs: [id]);
    var updatedExercise;
    if (recordsCount == 1) {
      updatedExercise = Exercise(id: id, name: name, description: description);
    }
    return updatedExercise;
  }

  Future<int> delete(int exerciseId) async {
    return _database
        .delete(table, where: '$colId = ?', whereArgs: [exerciseId]);
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

  Future<int> delete(int workoutId) async {
    return _database.delete(table, where: '$colId = ?', whereArgs: [workoutId]);
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

  Future<WorkoutEntry> insert(WorkoutEntry newEntry) async {
    var exercise = newEntry.exercise;
    var workout = newEntry.workout;
    var details = newEntry.details;
    var id = await _database.insert(
      table,
      {
        colExerciseId: exercise.id,
        colWorkoutId: workout.id,
        colDetails: details,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return WorkoutEntry(
        id: id, exercise: exercise, workout: workout, details: details);
  }

  Future<List<WorkoutEntry>> insertAll(List<WorkoutEntry> newEntries) async {
    var insertedEntries = <WorkoutEntry>[];
    for (var e in newEntries) {
      insertedEntries.add(await insert(e));
    }
    return insertedEntries;
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
    var newEntries = await _workoutEntriesDao.insert(newWorkout.id, workout.entities);
    newEntries.forEach((e) => newWorkout.addEntry(e));
    return newWorkout;
  }
  
  Future<Workout> updateWorkout(Workout workout) async {
    assert(workout.id != null);
    var updatedWorkout = await _workoutDao.update(workout);
    // Insert workout entities if added new
    // Update workout entries if changed already existed
    // Delete workout entries if deleted from workout

    return updatedWorkout;
  }

  Future<int> deleteWorkout(int id) {
    return _workoutDao.delete(id);
  }
}
