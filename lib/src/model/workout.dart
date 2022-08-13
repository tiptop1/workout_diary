import 'package:workout_diary/src/model/exercise_set.dart';

import 'entity.dart';

class Workout extends Entity {
  static const startTimeField = 'startTime';
  static const endTimeField = 'endTime';
  static const titleField = 'title';
  static const preCommentField = 'preComment';
  static const postCommentField = 'postComment';

  final DateTime? startTime;
  final DateTime? endTime;
  final String title;
  final String? preComment;
  final String? postComment;
  final List<ExerciseSet> _exerciseSets;

  Workout(
      {int? id,
      this.startTime,
      this.endTime,
      required this.title,
      this.preComment,
      this.postComment,
      List<ExerciseSet> exerciseSets = const []})
      : assert(title.isNotEmpty),
        _exerciseSets = List.unmodifiable(exerciseSets),
        super(id: id);

  Workout.formJson(Map<String, dynamic> json)
      : this(
            id: json[Entity.idField],
            startTime: json[startTimeField],
            endTime: json[endTimeField],
            title: json[titleField],
            preComment: json[preCommentField],
            postComment: json[postCommentField]);

  List<ExerciseSet> get exerciseSets => _exerciseSets;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();
    json[startTimeField] = startTime;
    json[endTimeField] = endTime;
    json[titleField] = title;
    json[preCommentField] = preComment;
    json[postCommentField] = postComment;
    json['exerciseSets'] = _exerciseSets;
    return json;
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
