import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart';

import '../model/exercise.dart';
import '../model/workout.dart';
import 'exercise_dao.dart';
import 'workout_entries_dao.dart';
import 'workouts_dao.dart';

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

  Future<int> updateExercise(Exercise updatedExercise) {
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
    workout.entities.forEach((e) => group
        .add(_workoutEntriesDao.insert(workoutId: newWorkout.id!, entry: e)));
    group.close();
    var newEntities = await group.future;
    newEntities.forEach((e) => newWorkout.addWorkoutEntry(e));
    return newWorkout;
  }

  Future<int> updateWorkout(Workout workout) async {
    assert(workout.id != null);
    int workoutId = workout.id!;
    await _workoutDao.update(workout);
      var oldEntityIds = await _workoutEntriesDao.findIdsByWorkoutId(workoutId);
      var newEntities = workout.entities;
      var group = FutureGroup();
      newEntities.forEach((e) {
        if (e.id == null) {
          group.add(
              _workoutEntriesDao.insert(workoutId: workoutId, entry: e));
        } else {
          group.add(
              _workoutEntriesDao.update(workoutId: workoutId, workoutEntry: e));
        }
      });
      oldEntityIds.forEach((oldId) {
        if (newEntities
                .map((e) => e.id)
                .firstWhere((newId) => newId == oldId) ==
            null) {
          group.add(_workoutEntriesDao.delete(oldId));
        }
      });
      group.close();
      var results = await group.future;


    return updatedWorkout;
  }

  Future<int> deleteWorkout(int id) {
    return _workoutDao.delete(id);
  }
}
