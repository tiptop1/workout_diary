import 'package:sqflite/sqflite.dart';

import '../model/workout_entry.dart';

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

  Future<List<int>> findIdsByWorkoutId(int workoutId) async {
    List<Map<String, dynamic>> records = await _database.query(table,
        distinct: true,
        columns: [colId],
        where: '$colWorkoutId = ?',
        whereArgs: [workoutId],
        orderBy: '$colId asc');
    return List.generate(records.length, (index) => records[index][colId]);
  }

  Future<WorkoutEntry> insert(
      {required int workoutId, required WorkoutEntry entry}) async {
    var id = await _database.insert(
      table,
      {
        colExerciseId: entry.exercise.id,
        colWorkoutId: workoutId,
        colDetails: entry.details,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return WorkoutEntry(
      id: id,
      exercise: entry.exercise,
      details: entry.details,
    );
  }

  Future<int> update(
      {required int workoutId, required WorkoutEntry workoutEntry}) {
    return _database.update(
        table,
        {
          colExerciseId: workoutEntry.exercise.id,
          colWorkoutId: workoutId,
          colDetails: workoutEntry.details
        },
        where: '$colId = ?',
        whereArgs: [workoutEntry.id]);
  }

  Future<int> delete(int id) {
    return _database.delete(table, where: '$colId = ?', whereArgs: [id]);
  }
}
