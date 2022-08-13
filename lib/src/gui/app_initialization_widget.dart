import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../config.dart';
import '../model/db/exercise_set_dao.dart';
import '../model/db/exercises_dao.dart';
import '../model/db/workouts_dao.dart';
import '../model/repository.dart';
import 'progress_widget.dart';

class AppInitializationWidget extends StatefulWidget {
  final Widget _child;

  const AppInitializationWidget({Key? key, required Widget child})
      : _child = child,
        super(key: key);

  @override
  State<AppInitializationWidget> createState() => _AppInitializationWidgetState();
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
    Widget w;
    if (_initializationComplete()) {
      w = Configuration(
        sharedPreferences: _sharedPreferences!,
        child: Repository(database: _database!, child: widget._child),
      );
    } else {
      w = ProgressWidget();
    }
    return w;
  }

  // Usually the _database will be completed.
  // Use it creating new Future e.g. _database.then(Future(...))
  Future<Database> _openDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), 'workout_diary.db'),
      onCreate: (db, version) {
        db.execute(
          'CREATE TABLE ${ExercisesDao.table}(${ExercisesDao.colId} INTEGER PRIMARY KEY AUTOINCREMENT, ${ExercisesDao.colName} TEXT NOT NULL, ${ExercisesDao.colDescription} TEXT)',
        );
        db.execute(
            'CREATE TABLE ${ExerciseSetsDao.table}(${ExerciseSetsDao.colId} INTEGER PRIMARY KEY AUTOINCREMENT, ${ExerciseSetsDao.colExerciseId} INTEGER NOT NULL, ${ExerciseSetsDao.colWorkoutId} INTEGER NOT NULL, ${ExerciseSetsDao.colDetails} TEXT, FOREIGN KEY (${ExerciseSetsDao.colExerciseId}) REFERENCES ${ExercisesDao.table}(${ExercisesDao.colId}) ON DELETE CASCADE, FOREIGN KEY (${ExerciseSetsDao.colWorkoutId}) REFERENCES ${WorkoutsDao.table}(${WorkoutsDao.colId}) ON DELETE CASCADE)');
        db.execute(
            'CREATE TABLE ${WorkoutsDao.table}(${WorkoutsDao.colId} INTEGER PRIMARY KEY AUTOINCREMENT, ${WorkoutsDao.colStartTime} INTEGER, ${WorkoutsDao.colEndTime} INTEGER, ${WorkoutsDao.colTitle} TEXT NOT NULL, ${WorkoutsDao.colPreComment} TEXT, ${WorkoutsDao.colPostComment} TEXT)');
      },
      version: 1,
    );
  }

  bool _initializationComplete() {
    return _database != null && _sharedPreferences != null;
  }
}
