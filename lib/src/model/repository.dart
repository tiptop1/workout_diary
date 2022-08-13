import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart';

import 'db/exercise_set_dao.dart';
import 'db/exercises_dao.dart';
import 'db/workouts_dao.dart';
import 'exercise.dart';
import 'workout.dart';

class Repository extends InheritedWidget {
  final ExercisesDao _exercisesDao;

  final WorkoutsDao _workoutDao;

  final ExerciseSetsDao _exerciseSetsDao;

  final Database database;

  Repository({Key? key, required this.database, required Widget child})
      : _exercisesDao = ExercisesDao(),
        _workoutDao = WorkoutsDao(),
        _exerciseSetsDao = ExerciseSetsDao(),
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
    return database.transaction((txn) => _exercisesDao.findAllSummaries(txn));
  }

  Future<Exercise?> findExerciseDetails(int id) {
    return database.transaction((txn) => _exercisesDao.findDetails(id,txn));
  }

  Future<Exercise> insertExercise(Exercise newExercise) {
    return database.transaction((txn) => _exercisesDao.insert(newExercise, txn));
  }

  Future<Exercise> updateExercise(Exercise updatedExercise) {
    return database.transaction((txn) => _exercisesDao.update(updatedExercise, txn));
  }

  Future<int> deleteExercise(int id) {
    return database.transaction((txn) => _exercisesDao.delete(id, txn));
  }

  Future<List<Workout>> findAllWorkoutSummaries() {
    return database.transaction((txn) => _workoutDao.findAllSummaries(txn));
  }

  Future<int> countExerciseSets(int exerciseId) {
    return database.transaction((txn) => _exerciseSetsDao.countByExercise(exerciseId, txn));
  }

  Future<Workout> insertWorkout(Workout workout) {
    return database.transaction((txn) => _workoutDao.insert(workout, txn));
  }

  Future<Workout> updateWorkout(Workout workout) {
    return database.transaction((txn) => _workoutDao.update(workout, txn));
  }

  Future<int> deleteWorkout(int id) {
    return database.transaction((txn) => _workoutDao.delete(id, txn));
  }
}
