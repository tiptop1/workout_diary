import 'package:sqflite/sqflite.dart';
import 'package:workout_diary/src/model/db/sqlite_result_codes.dart';

import '../exercise.dart';

class ExercisesDao {
  static const table = 'exercises';

  static const colId = 'id';
  static const colName = 'name';
  static const colDescription = 'description';

  /// Find all [Exercise] summaries - just id and name.
  /// Returns list of found [Exercise]s.
  Future<List<Exercise>> findAllSummaries(Transaction txn) async {
    List<Map<String, dynamic>> records =
        await txn.query(table, orderBy: colName);
    return List.generate(records.length, (index) {
      return Exercise(
        id: records[index][colId] as int?,
        name: records[index][colName] as String,
      );
    });
  }

  /// Find details of [Exercise] with given [id].
  /// Returns [Exercise] if found otherwise null.
  Future<Exercise?> findDetails(int id, Transaction txn) async {
    List<Map<String, dynamic>> records = await txn.query(
      table,
      where: '$colId = ?',
      whereArgs: [id],
    );
    var exercise;
    if (records.length == 1) {
      var record = records.first;
      exercise = Exercise(
        id: record[colId] as int?,
        name: record[colName] as String,
        description: record[colDescription] as String?,
      );
    }
    return exercise;
  }

  /// Insert [Excercise] into repository.
  /// Returns [Excercise] with id.
  Future<Exercise> insert(Exercise exercise, Transaction txn) async {
    assert(exercise.id == null);
    var name = exercise.name;
    var description = exercise.description;
    var id = await txn.insert(
      table,
      {
        colName: name,
        colDescription: description,
      },
      conflictAlgorithm: ConflictAlgorithm.rollback,
    );
    if (id == SqliteResultCodes.sqliteConstraint.code) {
      throw Exception('Could not insert exercise - result code: $id.');
    } else {
      return Exercise(
        id: id,
        name: name,
        description: description,
      );
    }
  }

  /// Update [Excrcise] in repository.
  /// Returns count of updated exercise records.
  Future<Exercise> update(Exercise exercise, Transaction txn) async {
    var resultCode = await txn.update(
        table, {colName: exercise.name, colDescription: exercise.description},
        where: '$colId = ?', whereArgs: [exercise.id], conflictAlgorithm: ConflictAlgorithm.rollback);
    if (resultCode != 1) {
      throw Exception('Could not update exercise with id:${exercise.id} - result code: $resultCode.');
    } else {
      return exercise;
    }
  }

  /// Delete [Exercise] with given [id].
  /// Returns count of deleted [Exercise]s.
  Future<int> delete(int id, Transaction txn) {
    return txn.delete(table, where: '$colId = ?', whereArgs: [id]);
  }
}
