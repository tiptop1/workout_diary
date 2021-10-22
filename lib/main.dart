import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:workout_diary/src/config.dart';
import 'package:workout_diary/src/domain.dart';
import 'package:workout_diary/src/gui.dart';
import 'package:workout_diary/src/repository.dart';

void main() {
  // Don't know how, but according to documentation:
  // "Avoid errors caused by flutter upgrade".
  WidgetsFlutterBinding.ensureInitialized();
  runApp(_InitializationWidget());
}

class _InitializationWidget extends StatefulWidget {
  @override
  State<_InitializationWidget> createState() => _InitializationWidgetState();
}

class _InitializationWidgetState extends State<_InitializationWidget> {
  SharedPreferences? _sharedPreferences;
  Database? _database;

  @override
  void initState() {
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
    super.initState();
  }

  @override
  void dispose() async {
    _database?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext ctx) {
    Widget widget;
    if (_initializationComplete()) {
      widget = Configuration(
        sharedPreferences: _sharedPreferences!,
        child: Repository(database: _database!, child: WorkoutDiaryWidget()),
      );
    } else {
      widget = CircularProgressIndicator();
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
            'CREATE TABLE ${Workout.table}(${Workout.colId} INTEGER PRIMARY KEY AUTOINCREMENT, ${Workout.colStartTime} INTEGER NOT NULL, ${Workout.colEndTime} INTEGER NOT NULL, ${Workout.colTitle} TEXT, ${Workout.colPreComment} TEXT, ${Workout.colPostComment} TEXT)');
      },
      version: 1,
    );
  }

  bool _initializationComplete() {
    return _database != null && _sharedPreferences != null;
  }
}
