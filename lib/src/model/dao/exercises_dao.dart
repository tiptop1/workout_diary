import 'package:sqflite/sqlite_api.dart';

import '../exercise.dart';

class ExercisesDao {
  static const table = 'exercises';

  static const colId = 'id';
  static const colName = 'name';
  static const colDescription = 'description';

  final Database _db;

  ExercisesDao(Database db) : _db = db;

  /// Returns list of all [Exercise]s.
  Future<List<Exercise>> findAll() async {
    List<Map<String, dynamic>> records =
        await _db.query(table, orderBy: colName);
    return List.generate(records.length, (i) {
      var record = records[i];
      return Exercise(
        id: record[colId] as int,
        name: record[colName] as String,
        description: record[colDescription] as String,
      );
    });
  }

  /// Insert [exercise] and returns new id for it.
  Future<Exercise> insert(Exercise exercise) async {
    assert(exercise.id == null);
    var exerciseId = await _db.insert(
      table,
      _toMap(exercise),
      conflictAlgorithm: ConflictAlgorithm.rollback,
    );
    return exercise.copyWith(id: exerciseId);
  }

  /// Update [exercise] and returns true if successful.
  Future<Exercise> update(Exercise exercise) async {
    var updatedRowsCount = await _db.update(table, _toMap(exercise),
        where: '$colId = ?',
        whereArgs: [exercise.id],
        conflictAlgorithm: ConflictAlgorithm.rollback);
    return updatedRowsCount == 1
        ? exercise
        : throw Exception('Could not update exercise with id: ${exercise.id}.');
  }

  /// Delete exercise with given [id] and returns true if successful.
  Future<bool> delete(int id) async {
    var deletedRowsCount =
        await _db.delete(table, where: '$colId = ?', whereArgs: [id]);
    return deletedRowsCount == 1;
  }

  Map<String, Object?> _toMap(Exercise exercise) => {
        colName: exercise.name,
        colDescription: exercise.description,
      };
}
