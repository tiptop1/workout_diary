import 'package:equatable/equatable.dart';
import 'package:floor/floor.dart';

/// Natural key: [name]
@Entity(tableName: 'exercises')
@Index(name: 'UX_Exercise_name', value: ['name'])
class ExerciseModel extends Equatable {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final String name;
  final String? description;

  const ExerciseModel({
    this.id,
    required this.name,
    this.description,
  });

  @override
  List<Object?> get props => [id, name];

}
