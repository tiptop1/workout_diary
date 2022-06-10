abstract class Entity {
  static const idField = 'id';

  final int? id;

  const Entity({this.id});

  Entity.fromJson(Map<String, dynamic> json) : id = json[idField];

  Map<String, dynamic> toJson() => {idField: id};
}

class Exercise extends Entity {
  static const nameField = 'name';
  static const descriptionField = 'description';

  final String name;
  final String? description;

  Exercise({int? id, required this.name, this.description})
      : assert(name.isNotEmpty),
        super(id: id);

  Exercise.fromJson(Map<String, dynamic> json)
      : this(
            id: json[Entity.idField],
            name: json[nameField],
            description: json[descriptionField]);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();
    json[nameField] = name;
    json[descriptionField] = description;
    return json;
  }

  @override
  String toString() {
    return toJson().toString();
  }
}

class WorkoutEntry extends Entity {
  static const exerciseField = 'exercise';
  static const detailsField = 'details';

  final Exercise exercise;
  final String details;

  const WorkoutEntry({int? id, required this.exercise, required this.details})
      : super(id: id);

  WorkoutEntry.fromJson(Map<String, dynamic> json)
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
}

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
