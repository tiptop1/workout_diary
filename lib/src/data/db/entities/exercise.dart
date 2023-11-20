import 'package:floor/floor.dart';

@entity
@Index(name: 'UX_Exercise_name', value: ['name'])
class Exercise {
  @PrimaryKey(autoGenerate: true)
  final int id;
  final String name;
  final String? description;

  const Exercise(this.id, this.name, this.description);
}
