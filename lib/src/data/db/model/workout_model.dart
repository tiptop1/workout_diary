import 'package:equatable/equatable.dart';
import 'package:floor/floor.dart';

@Entity(tableName: 'workouts')
class WorkoutModel extends Equatable {
  @primaryKey
  final int id;
  final String title;
  final DateTime startTime;
  final DateTime? endTime;
  final String? comment;

  const WorkoutModel({
    required this.id,
    required this.title,
    required this.startTime,
    this.endTime,
    this.comment,
  });

  @override
  List<Object?> get props => [id];
}
