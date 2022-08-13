import 'package:sqflite/sqflite.dart';

import '../exercise_set.dart';

class ExerciseSetsDao {
  static const table = 'exercise_sets';

  static const colId = 'id';
  static const colExerciseId = 'exercise_id';
  static const colWorkoutId = 'workout_id';
  static const colDetails = 'details';

  Future<int> countByExercise(int exerciseId, Transaction txn) async {
    const countAlias = 'entriesCount';
    List<Map<String, Object?>> result = await txn.rawQuery(
        'SELECT count(*) AS \'$countAlias\' FROM $table WHERE $colExerciseId = ?',
        [exerciseId]);
    return result.first[countAlias] as int;
  }

  Future<List<int>> findIdsByWorkoutId(int workoutId, Transaction txn) async {
    List<Map<String, dynamic>> records = await txn.query(table,
        distinct: true,
        columns: [colId],
        where: '$colWorkoutId = ?',
        whereArgs: [workoutId],
        orderBy: '$colId asc');
    return List.generate(records.length, (index) => records[index][colId]);
  }

  Future<List<ExerciseSet>> insert(int workoutId,
      List<ExerciseSet> exerciseSets, Transaction txn) async {
    var batch = txn.batch();
    for (var es in exerciseSets) {
      batch.insert(
          table,
          {
            colExerciseId: es.exercise.id,
            colWorkoutId: workoutId,
            colDetails: es.details,
          },
          conflictAlgorithm: ConflictAlgorithm.rollback);
    }
    var insertResult = await batch.commit();
    if (insertResult is int) {
      throw Exception(
          'Could not insert exercise set because of error code: $insertResult.');
    } else if (insertResult is List<int>) {
      return _toExerciseSet(exerciseSets, insertResult);
    } else {
      throw Exception(
          'Insert result has unknown type: ${insertResult.runtimeType}.');
    }
  }

  List<ExerciseSet> _toExerciseSet(List<ExerciseSet> exerciseSets,
      List<int> insertedIds) {
    assert(exerciseSets.length == insertedIds.length,
    'Exercise set list length (${exerciseSets
        .length} different than inserted ids list length (${insertedIds
        .length}).');
    return List.generate(exerciseSets.length, (i) =>
        ExerciseSet(
          id: insertedIds[i],
          exercise: exerciseSets[i].exercise,
          details: exerciseSets[i].details,
        ));
  }
}
