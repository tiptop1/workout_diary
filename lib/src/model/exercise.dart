import 'entity.dart';

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
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Exercise &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ description.hashCode;

  @override
  String toString() {
    return toJson().toString();
  }
}
