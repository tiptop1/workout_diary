class Exercise {
  static const table = 'exercises';

  static const colId = 'id';
  static const colName = 'name';
  static const colDescription = 'description';

  final int? id;
  final String name;
  final String? description;

  Exercise({this.id, required this.name, this.description});

  @override
  String toString() {
    return 'Exercise{id: $id, name: $name, description: $description}';
  }
}

class WorkoutEntry {
  static const table = 'workout_entries';

  static const colId = 'id';
  static const colExerciseId = 'exercise_id';
  static const colWorkoutId = 'workout_id';
  static const colDetails = 'details';

  final int? id;
  final Exercise exercise;
  final Workout workout;
  final String details;

  WorkoutEntry(
      {this.id,
      required this.exercise,
      required this.workout,
      required this.details});

  @override
  String toString() {
    return 'WorkoutEntry{id: $id, exercise: ${exercise.toString()}, workout: ${workout.toString()}, details: $details}';
  }
}

class Workout {
  static const table = 'workouts';

  static const colId = 'id';
  static const colStartTime = 'startTime';
  static const colEndTime = 'endTime';
  static const colTitle = 'title';
  static const colPreComment = 'preComment';
  static const colPostComment = 'postComment';

  final int? id;
  final DateTime? startTime;
  final DateTime? endTime;
  final List<WorkoutEntry> entries;
  final String? title;
  final String? preComment;
  final String? postComment;

  Workout(
      {this.id,
      this.startTime,
      this.endTime,
      this.entries = const [],
      required this.title,
      this.preComment,
      this.postComment});

  @override
  String toString() {
    var entriesStr = '';
    for (var i = 0; i < entries.length; i++) {
      entriesStr += entries[i].toString();
      if (i < entries.length - 1) {
        entriesStr += ',';
      }
    }
    return 'Workout{id: $id, startTime: $startTime, endTime: $endTime, entries: [$entriesStr], title: $title, preComment: $preComment, postComment: $postComment}';
  }
}
