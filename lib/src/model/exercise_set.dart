import 'entity.dart';
import 'exercise.dart';

class ExerciseSet extends Entity {
  // TODO: Add order column
  static const exerciseField = 'exercise';
  static const detailsField = 'details';

  final Exercise exercise;
  final String? details;

  const ExerciseSet({int? id, required this.exercise, this.details})
      : super(id: id);

  ExerciseSet.fromJson(Map<String, dynamic> json)
      : this(
            id: json[Entity.idField],
            exercise: Exercise.fromJson(json),
            details: json[detailsField]);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();
    json[exerciseField] = exercise.toJson();
    json[detailsField] = details;
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
          other is ExerciseSet &&
          runtimeType == other.runtimeType &&
          exercise == other.exercise &&
          details == other.details;

  @override
  int get hashCode => super.hashCode ^ exercise.hashCode ^ details.hashCode;
}
