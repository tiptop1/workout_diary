import 'dart:async';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'dao/exercises_dao.dart';
import 'dao/workouts_dao.dart';
import 'exercise.dart';
import 'workout.dart';

class Repository {
  static const _defaultDbName = 'workout_diary.db';
  static const _defaultDbVersion = 1;

  late final Database _db;
  late final ExercisesDao _exercisesDao;
  late final WorkoutsDao _workoutsDao;

  Repository._internal(Database db)
      : _db = db,
        _exercisesDao = ExercisesDao(db),
        _workoutsDao = WorkoutsDao(db);

  static Future<Repository> init({String? dbPath, int? dbVersion}) async {
    var db = await openDatabase(
      dbPath ?? join(await getDatabasesPath(), _defaultDbName),
      version: dbVersion ?? _defaultDbVersion,
      onCreate: (db, version) {
        db.execute(
          'CREATE TABLE ${ExercisesDao.table}(${ExercisesDao.colId} INTEGER PRIMARY KEY AUTOINCREMENT, ${ExercisesDao.colName} TEXT NOT NULL, ${ExercisesDao.colDescription} TEXT)',
        );
        db.execute(
            'CREATE TABLE ${WorkoutsDao.tableExerciseSets}(${WorkoutsDao.colExerciseSetId} INTEGER PRIMARY KEY AUTOINCREMENT, ${WorkoutsDao.colExerciseSetExerciseId} INTEGER NOT NULL, ${WorkoutsDao.colExerciseSetWorkoutId} INTEGER NOT NULL, ${WorkoutsDao.colExerciseSetDetails} TEXT, FOREIGN KEY (${WorkoutsDao.colExerciseSetExerciseId}) REFERENCES ${ExercisesDao.table}(${ExercisesDao.colId}) ON DELETE CASCADE, FOREIGN KEY (${WorkoutsDao.colExerciseSetWorkoutId}) REFERENCES ${WorkoutsDao.tableWorkouts}(${WorkoutsDao.colWorkoutId}) ON DELETE CASCADE)');
        db.execute(
            'CREATE TABLE ${WorkoutsDao.tableWorkouts}(${WorkoutsDao.colWorkoutId} INTEGER PRIMARY KEY AUTOINCREMENT, ${WorkoutsDao.colWorkoutStartTime} INTEGER, ${WorkoutsDao.colWorkoutEndTime} INTEGER, ${WorkoutsDao.colWorkoutTitle} TEXT NOT NULL, ${WorkoutsDao.colWorkoutPreComment} TEXT, ${WorkoutsDao.colWorkoutPostComment} TEXT)');
      },
    );
    return Repository._internal(db);
  }

  void dispose() => _db.close();

  Future<List<Exercise>> findAllExercises() => _exercisesDao.findAll();

  Future<Exercise> insertExercise(Exercise exercise) => _exercisesDao.insert(exercise);

  Future<Exercise> updateExercise(Exercise exercise) => _exercisesDao.update(exercise);

  Future<bool> deleteExercise(int id) => _exercisesDao.delete(id);

  Future<List<Workout>> findAllWorkouts(List<Exercise> exercises) => _workoutsDao.findAll(exercises);

  Future<Workout> insertWorkout(Workout workout) => _workoutsDao.insertWorkout(workout);

  Future<Workout> updateWorkout(Workout workout) => _workoutsDao.updateWorkout(workout);

  Future<bool> deleteWorkout(int id) => _workoutsDao.deleteWorkout(id);
}
