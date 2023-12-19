import 'package:equatable/equatable.dart';
import 'package:floor/floor.dart';

@Entity(tableName: 'exercises')
class ExerciseModel extends Equatable {
  @primaryKey
  final int id;
  final String name;
  final String? description;

  const ExerciseModel({
    required this.id,
    required this.name,
    this.description,
  });

  @override
  List<Object?> get props => [id];

}
