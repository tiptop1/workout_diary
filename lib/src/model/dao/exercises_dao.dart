import 'package:sqflite/sqlite_api.dart';

import '../exercise.dart';

class ExercisesDao {
  static const table = 'exercises';

  static const colId = 'id';
  static const colName = 'name';
  static const colDescription = 'description';

  final Database _db;

  ExercisesDao(Database db) : _db = db;

  Future<List<Exercise>> findAllSummaries() async {
    List<Map<String, dynamic>> records =
        await _db.query(table, orderBy: colName);
    return List.generate(records.length, (i) {
      return Exercise(
        id: records[i][colId] as int,
        name: records[i][colName] as String,
      );
    });
  }

  Future<Exercise?> findDetails(int id) async {
    List<Map<String, dynamic>> records = await _db.query(
      table,
      where: '$colId = ?',
      whereArgs: [id],
    );
    var exercise;
    if (records.length == 1) {
      var record = records.first;
      exercise = Exercise(
        id: record[colId] as int,
        name: record[colName] as String,
        description: record[colDescription] as String?,
      );
    }
    return exercise;
  }

  Future<Exercise> insert(Exercise exercise) async {
    assert(exercise.id == null);
    var id = await _db.insert(
      table,
      _toMap(exercise),
      conflictAlgorithm: ConflictAlgorithm.rollback,
    );
    return exercise.copyWith(id: id);
  }

  Future<Exercise?> update(Exercise exercise) async {
    var updatedRowsCount = await _db.update(table, _toMap(exercise),
        where: '$colId = ?',
        whereArgs: [exercise.id],
        conflictAlgorithm: ConflictAlgorithm.rollback);
    return updatedRowsCount == 1 ? exercise : null;
  }

  Future<int> delete(int id) =>
      _db.delete(table, where: '$colId = ?', whereArgs: [id]);

  Map<String, Object?> _toMap(Exercise exercise) => {
        colName: exercise.name,
        colDescription: exercise.description,
      };
}
