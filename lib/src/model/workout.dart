import 'package:workout_diary/src/model/workout_entry.dart';

import 'entity.dart';

class Workout extends Entity {
  static const startTimeField = 'startTime';
  static const endTimeField = 'endTime';
  static const titleField = 'title';
  static const preCommentField = 'preComment';
  static const postCommentField = 'postComment';
  static const entitiesField = 'entities';

  final DateTime? startTime;
  final DateTime? endTime;
  final String title;
  final String? preComment;
  final String? postComment;
  final List<WorkoutEntry> _entities = [];

  Workout(
      {int? id,
      this.startTime,
      this.endTime,
      required this.title,
      this.preComment,
      this.postComment})
      : assert(title.isNotEmpty),
        super(id: id);

  Workout.formJson(Map<String, dynamic> json)
      : this(
            id: json[Entity.idField],
            startTime: json[startTimeField],
            endTime: json[endTimeField],
            title: json[titleField],
            preComment: json[preCommentField],
            postComment: json[postCommentField]);

  List<WorkoutEntry> get entities => List.unmodifiable(_entities);

  void addWorkoutEntry(WorkoutEntry entry) => _entities.add(entry);

  void removeWorkoutEntry(WorkoutEntry entry) =>
      _entities.remove(_entities.firstWhere((e) => entry.id == e.id));

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();
    json[startTimeField] = startTime;
    json[endTimeField] = endTime;
    json[titleField] = title;
    json[preCommentField] = preComment;
    json[postCommentField] = postComment;
    json[entitiesField] = _entities;
    return json;
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
