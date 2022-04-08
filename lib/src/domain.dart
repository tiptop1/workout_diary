abstract class Entity {
  final int? id;

  const Entity({this.id});
}

class Exercise extends Entity {
  static const table = 'exercises';

  static const colId = 'id';
  static const colName = 'name';
  static const colDescription = 'description';

  final String name;
  final String? description;

  Exercise({int? id, required this.name, this.description}) : super(id: id);

  @override
  String toString() {
    return 'Exercise{id: $id, name: $name, description: $description}';
  }
}

class WorkoutEntry extends Entity {
  static const table = 'workout_entries';

  static const colId = 'id';
  static const colExerciseId = 'exercise_id';
  static const colWorkoutId = 'workout_id';
  static const colDetails = 'details';

  final Exercise exercise;
  final Workout workout;
  final String details;

  WorkoutEntry(
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
  static const table = 'workouts';

  static const colId = 'id';
  static const colStartTime = 'startTime';
  static const colEndTime = 'endTime';
  static const colTitle = 'title';
  static const colPreComment = 'preComment';
  static const colPostComment = 'postComment';

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
      : super(id: id);

  @override
  String toString() {
    return 'Workout{id: $id, startTime: $startTime, endTime: $endTime, title: $title, preComment: $preComment, postComment: $postComment}';
  }
}
