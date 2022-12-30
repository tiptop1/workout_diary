import 'entity.dart';
import 'exercise_set.dart';

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

  Workout copyWith({
    int? id,
    DateTime? startTime,
    DateTime? endTime,
    String? title,
    String? preComment,
    String? postComment,
    List<ExerciseSet>? exerciseSets,
  }) {
    return Workout(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      title: title ?? this.title,
      preComment: preComment ?? this.preComment,
      postComment: postComment ?? this.postComment,
      exerciseSets: exerciseSets ?? this._exerciseSets,
    );
  }

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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is Workout &&
          runtimeType == other.runtimeType &&
          startTime == other.startTime &&
          endTime == other.endTime &&
          title == other.title &&
          preComment == other.preComment &&
          postComment == other.postComment &&
          _exerciseSets == other._exerciseSets;

  @override
  int get hashCode =>
      super.hashCode ^
      startTime.hashCode ^
      endTime.hashCode ^
      title.hashCode ^
      preComment.hashCode ^
      postComment.hashCode ^
      _exerciseSets.hashCode;
}
