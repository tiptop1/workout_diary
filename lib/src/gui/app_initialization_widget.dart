import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../config.dart';
import '../domain.dart';
import '../repository.dart';
import 'progress_widget.dart';
import 'workout_diary_widget.dart';

class AppInitializationWidget extends StatefulWidget {
  @override
  State<AppInitializationWidget> createState() =>
      _AppInitializationWidgetState();
}

class _AppInitializationWidgetState extends State<AppInitializationWidget> {
  SharedPreferences? _sharedPreferences;
  Database? _database;

  @override
  void initState() {
    super.initState();
    FutureGroup futures = FutureGroup();
    futures.add(SharedPreferences.getInstance());
    futures.add(_openDatabase());
    futures.close();
    futures.future.then(
      (results) {
        setState(
          () {
            _sharedPreferences = results[0];
            _database = results[1];
          },
        );
      },
    );
  }

  @override
  void dispose() async {
    _database?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget widget;
    if (_initializationComplete()) {
      widget = Configuration(
        sharedPreferences: _sharedPreferences!,
        child: Repository(database: _database!, child: WorkoutDiaryWidget()),
      );
    } else {
      widget = ProgressWidget();
    }
    return widget;
  }

  // Usually the _database will be completed.
  // Use it creating new Future e.g. _database.then(Future(...))
  Future<Database> _openDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), 'workout_diary.db'),
      onCreate: (db, version) {
        db.execute(
          'CREATE TABLE ${Exercise.table}(${Exercise.colId} INTEGER PRIMARY KEY AUTOINCREMENT, ${Exercise.colName} TEXT NOT NULL, ${Exercise.colDescription} TEXT)',
        );
        db.execute(
            'CREATE TABLE ${WorkoutEntry.table}(${WorkoutEntry.colId} INTEGER PRIMARY KEY AUTOINCREMENT, ${WorkoutEntry.colExerciseId} INTEGER NOT NULL, ${WorkoutEntry.colWorkoutId} INTEGER NOT NULL, ${WorkoutEntry.colDetails} TEXT, FOREIGN KEY (${WorkoutEntry.colExerciseId}) REFERENCES ${Exercise.table}(${Exercise.colId}), FOREIGN KEY (${WorkoutEntry.colWorkoutId}) REFERENCES ${Workout.table}(${Workout.colId}))');
        db.execute(
            'CREATE TABLE ${Workout.table}(${Workout.colId} INTEGER PRIMARY KEY AUTOINCREMENT, ${Workout.colStartTime} INTEGER, ${Workout.colEndTime} INTEGER, ${Workout.colTitle} TEXT NOT NULL, ${Workout.colPreComment} TEXT, ${Workout.colPostComment} TEXT)');
      },
      version: 1,
    );
  }

  bool _initializationComplete() {
    return _database != null && _sharedPreferences != null;
  }
}
