abstract class Entity {
  final int? id;

  const Entity({this.id});
}

class Exercise extends Entity {
  final String name;
  final String? description;

  Exercise({int? id, required this.name, this.description})
      : assert(name.isNotEmpty),
        super(id: id);

  @override
  String toString() {
    return 'Exercise{id: $id, name: $name, description: $description}';
  }
}

class WorkoutEntry extends Entity {
  final Exercise exercise;
  final Workout workout;
  final String details;

  const WorkoutEntry(
      {int? id,
      required this.exercise,
      required this.workout,
      required this.details})
      : super(id: id);

  @override
  String toString() {
    return 'WorkoutEntry{id: $id, exercise: ${exercise.toString()}, workout: ${workout.toString()}, details: $details}';
  }
}

class Workout extends Entity {
  final DateTime? startTime;
  final DateTime? endTime;
  final String title;
  final String? preComment;
  final String? postComment;

  Workout(
      {int? id,
      this.startTime,
      this.endTime,
      required this.title,
      this.preComment,
      this.postComment})
      : assert(title.isNotEmpty),
        super(id: id);

  @override
  String toString() {
    return 'Workout{id: $id, startTime: $startTime, endTime: $endTime, title: $title, preComment: $preComment, postComment: $postComment}';
  }
}
