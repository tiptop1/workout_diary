import 'package:equatable/equatable.dart';
import 'package:floor/floor.dart';

/// Natural key: [startTime]
@Entity(tableName: 'workouts')
@Index(name: 'UX_Workout_startTime', value: ['startTime'])
class WorkoutModel extends Equatable {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final String title;
  final DateTime startTime;
  final DateTime? endTime;
  final String? comment;

  const WorkoutModel({
    this.id,
    required this.title,
    required this.startTime,
    this.endTime,
    this.comment,
  });

  @override
  List<Object?> get props => [id, startTime];
}
