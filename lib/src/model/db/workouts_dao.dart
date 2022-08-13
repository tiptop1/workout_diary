import 'package:sqflite/sqflite.dart';

import '../exercise_set.dart';
import '../workout.dart';
import 'exercise_set_dao.dart';

class WorkoutsDao {
  static const table = 'workouts';

  static const colId = 'id';
  static const colStartTime = 'startTime';
  static const colEndTime = 'endTime';
  static const colTitle = 'title';
  static const colPreComment = 'preComment';
  static const colPostComment = 'postComment';

  const WorkoutsDao();

  Future<List<Workout>> findAllSummaries(Transaction txn) async {
    List<Map<String, dynamic>> records = await txn.query(
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

  Future<Workout> insert(Workout workout, Transaction txn) async {
    var workoutId = await _insertWorkout(workout, txn);
    var exeSetDao = ExerciseSetsDao();
    List<ExerciseSet> exerciseSets = await exeSetDao.insert(workoutId, workout.exerciseSets, txn);
    return _createNewWorkout(workoutId, workout, exerciseSets.map((es) => es.id!).toList());
  }

  /// Update [Workout].
  /// Returns count of updated workout records.
  Future<Workout> update(Workout workout, Transaction txn) {
    throw Exception('Not implemented yet!');
  }

  /// Delete [Workout] with given [id].
  /// Returns number of deleted [Workout]s.
  Future<int> delete(int id, Transaction txn) async {
    // TODO: Make sure that deleting workout cascade delete exercise sets
    return txn.delete(table, where: '$colId = ?', whereArgs: [id]);
  }

  Future<int> _insertWorkout(Workout workout, Transaction txn) {
    return txn.insert(
      table,
      {
        colStartTime: workout.startTime,
        colEndTime: workout.endTime,
        colTitle: workout.title,
        colPreComment: workout.preComment,
        colPostComment: workout.postComment
      },
      conflictAlgorithm: ConflictAlgorithm.rollback,
    );
  }

  Workout _createNewWorkout(
      int workoutId, Workout oldWorkout, List<int> insertedExerciseSetIds) {
    assert(insertedExerciseSetIds.length == oldWorkout.exerciseSets.length);
    var newExerciseSets = <ExerciseSet>[];
    for (var i = 0; i < insertedExerciseSetIds.length; i++) {
      var oldExerciseSet = oldWorkout.exerciseSets[i];
      newExerciseSets.add(ExerciseSet(
        id: insertedExerciseSetIds[i],
        exercise: oldExerciseSet.exercise,
        details: oldExerciseSet.details,
      ));
    }
    return Workout(
      id: workoutId,
      startTime: oldWorkout.startTime,
      endTime: oldWorkout.endTime,
      title: oldWorkout.title,
      preComment: oldWorkout.preComment,
      postComment: oldWorkout.postComment,
      exerciseSets: newExerciseSets,
    );
  }
}
