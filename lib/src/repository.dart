import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:workout_diary/src/domain.dart';

// Usually the _database will be completed.
// Use it creating new Future e.g. _database.then(Future(...))
Future<Database>? _database;

Future<Database> getDatabase() async {
  _database ??= openDatabase(
    join(await getDatabasesPath(), 'workout_diary.db'),
    onCreate: (db, version) {
      db.execute(
        'CREATE TABLE ${Exercise.table}(${Exercise
            .colId} INTEGER PRIMARY KEY AUTOINCREMENT, ${Exercise
            .colName} TEXT NOT NULL, ${Exercise.colDescription} TEXT)',
      );
      db.execute(
          'CREATE TABLE ${WorkoutEntry.table}(${WorkoutEntry
              .colId} INTEGER PRIMARY KEY AUTOINCREMENT, ${WorkoutEntry
              .colExerciseId} INTEGER NOT NULL, ${WorkoutEntry
              .colWorkoutId} INTEGER NOT NULL, ${WorkoutEntry
              .colDetails} TEXT, FOREIGN KEY (${WorkoutEntry
              .colExerciseId}) REFERENCES ${Exercise.table}(${Exercise
              .colId}), FOREIGN KEY (${WorkoutEntry
              .colWorkoutId}) REFERENCES ${Workout.table}(${Workout.colId}))');
      db.execute(
          'CREATE TABLE ${Workout.table}(${Workout
              .colId} INTEGER PRIMARY KEY AUTOINCREMENT, ${Workout
              .colStartTime} INTEGER NOT NULL, ${Workout
              .colEndTime} INTEGER NOT NULL, ${Workout.colTitle} TEXT, ${Workout
              .colPreComment} TEXT, ${Workout.colPostComment} TEXT)');
    },
    version: 1,
  );
  return _database!;
}

class ExercisesDao {

  /// Find all [Exercise] summaries - just id and name.
  /// Useful to show list of all exercises.
  Future<List<Exercise>> findAllSummaries(int pageOffset, int pageLimit) async {
    var database = await getDatabase();
    List<Map<String, dynamic>> records =
    await database.query(Exercise.table, offset: pageOffset, limit: pageLimit);
    return List.generate(records.length, (i) {
      return Exercise(
        id: records[i][Exercise.colId] as int?,
        name: records[i][Exercise.colName] as String,
      );
    });
  }

  /// Find details of [Exercise] with given [id].
  Future<Exercise?> findDetails(int id) async {
    var database = await getDatabase();
    List<Map<String, dynamic>> records =
    await database.query(
        Exercise.table, where: '${Exercise.colId} = ?', whereArgs: [id]);
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
  Future<List<Workout>> findAllSummaries(int pageOffset, int pageLimit) async {
    var database = await getDatabase();
    List<Map<String, dynamic>> records = await database.query(
        Workout.table, offset: pageOffset, limit: pageLimit);
    return List.generate(records.length, (i) {
      var startTimeMillis = records[i][Workout.colStartTime];
      var endTimeMillis = records[i][Workout.colEndTime];
      return Workout(id: records[i][Workout.colId] as int?,
        startTime: startTimeMillis != null ? DateTime.fromMillisecondsSinceEpoch(startTimeMillis) : null,
        endTime: endTimeMillis != null ? DateTime.fromMillisecondsSinceEpoch(endTimeMillis) : null,
        title: records[i][Workout.colTitle]);
    });
  }

}

abstract class DataRepository {
  List<Exercise> findExercises(int pageOffset, int pageLimit);

  List<Workout> findWorkouts(int pageOffest, int pageLimit);
}
