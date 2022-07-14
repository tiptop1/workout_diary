import 'package:sqflite/sqflite.dart';

import '../model/exercise.dart';

class ExercisesDao {
  static const table = 'exercises';

  static const colId = 'id';
  static const colName = 'name';
  static const colDescription = 'description';

  final Database _database;

  const ExercisesDao(this._database);

  /// Find all [Exercise] summaries - just id and name.
  /// Returns list of found [Exercise]s.
  Future<List<Exercise>> findAllSummaries() async {
    List<Map<String, dynamic>> records =
        await _database.query(table, orderBy: colName);
    return List.generate(records.length, (index) {
      return Exercise(
        id: records[index][colId] as int?,
        name: records[index][colName] as String,
      );
    });
  }

  /// Find details of [Exercise] with given [id].
  /// Returns [Exercise] if found otherwise null.
  Future<Exercise?> findDetails(int id) async {
    List<Map<String, dynamic>> records = await _database.query(
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
  Future<Exercise> insert(Exercise exercise) async {
    assert(exercise.id == null);
    var name = exercise.name;
    var description = exercise.description;
    var id = await _database.insert(
      table,
      {
        colName: name,
        colDescription: description,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return Exercise(
      id: id,
      name: name,
      description: description,
    );
  }

  /// Update [Excrcise] in repository.
  /// Returns count of updated exercise records.
  Future<int> update(Exercise exercise) {
    return _database.update(
        table, {colName: exercise.name, colDescription: exercise.description},
        where: '$colId = ?', whereArgs: [exercise.id]);
  }

  /// Delete [Exercise] with given [id].
  /// Returns count of deleted [Exercise]s.
  Future<int> delete(int id) async {
    return _database.delete(table, where: '$colId = ?', whereArgs: [id]);
  }
}
