import 'package:sqflite/sqflite.dart';

import '../model/workout.dart';

class WorkoutsDao {
  static const table = 'workouts';

  static const colId = 'id';
  static const colStartTime = 'startTime';
  static const colEndTime = 'endTime';
  static const colTitle = 'title';
  static const colPreComment = 'preComment';
  static const colPostComment = 'postComment';
  final Database _database;

  const WorkoutsDao(this._database);

  Future<List<Workout>> findAllSummaries() async {
    List<Map<String, dynamic>> records = await _database.query(
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

  Future<Workout> insert(Workout newWorkout) async {
    var title = newWorkout.title;
    var startTime = newWorkout.startTime;
    var endTime = newWorkout.endTime;
    var preComment = newWorkout.preComment;
    var postComment = newWorkout.postComment;

    var id = await _database.insert(
      table,
      {
        colTitle: title,
        colStartTime: startTime?.millisecondsSinceEpoch,
        colEndTime: endTime?.millisecondsSinceEpoch,
        colPreComment: preComment,
        colPostComment: postComment,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return Workout(
        id: id,
        title: title,
        startTime: startTime,
        endTime: endTime,
        preComment: preComment,
        postComment: postComment);
  }

  /// Update [Workout].
  /// Returns count of updated workout records.
  Future<int> update(Workout workout) {
    assert(workout.id != null);
    return _database.update(
        table,
        {
          colTitle: workout.title,
          colStartTime: workout.startTime?.millisecondsSinceEpoch,
          colEndTime: workout.endTime?.millisecondsSinceEpoch,
          colPreComment: workout.preComment,
          colPostComment: workout.postComment,
        },
        where: '$colId = ?',
        whereArgs: [workout.id]);
  }

  /// Delete [Workout] with given [id].
  /// Returns number of deleted [Workout]s.
  Future<int> delete(int id) async {
    return _database.delete(table, where: '$colId = ?', whereArgs: [id]);
  }
}
