import 'package:floor/floor.dart';

@entity
@Index(name: 'UX_Workout_title_startTime', value: ['title', 'startTime'])
class Workout {
  @PrimaryKey(autoGenerate: true)
  final int id;
  final String title;
  final DateTime startTime;
  final DateTime? endTime;
  final String? comment;

  const Workout(this.id, this.title, this.startTime, this.endTime, this.comment);
}