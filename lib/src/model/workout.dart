import 'entity.dart';
import 'exercise_set.dart';

class Workout extends Entity {
  static const startTimeField = 'startTime';
  static const endTimeField = 'endTime';
  static const titleField = 'title';
  static const commentField = 'comment';

  final DateTime? startTime;
  final DateTime? endTime;
  final String title;
  final String? comment;
  final List<ExerciseSet> _exerciseSets;

  Workout(
      {int? id,
      this.startTime,
      this.endTime,
      required this.title,
      this.comment,
      List<ExerciseSet> exerciseSets = const []})
      : assert(title.isNotEmpty),
        _exerciseSets = List.unmodifiable(exerciseSets),
        super(id: id);

  Workout copyWith({
    int? id,
    DateTime? startTime,
    DateTime? endTime,
    String? title,
    String? comment,
    List<ExerciseSet>? exerciseSets,
  }) {
    return Workout(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      title: title ?? this.title,
      comment: comment ?? this.comment,
      exerciseSets: exerciseSets ?? this._exerciseSets,
    );
  }

  Workout.formJson(Map<String, dynamic> json)
      : this(
            id: json[Entity.idField],
            startTime: json[startTimeField],
            endTime: json[endTimeField],
            title: json[titleField],
            comment: json[commentField]);

  List<ExerciseSet> get exerciseSets => _exerciseSets;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();
    json[startTimeField] = startTime;
    json[endTimeField] = endTime;
    json[titleField] = title;
    json[commentField] = comment;
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
          comment == other.comment &&
          _exerciseSets == other._exerciseSets;

  @override
  int get hashCode =>
      super.hashCode ^
      startTime.hashCode ^
      endTime.hashCode ^
      title.hashCode ^
      comment.hashCode ^
      _exerciseSets.hashCode;
}
