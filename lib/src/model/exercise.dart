import 'entity.dart';

class Exercise extends Entity {
  static const nameField = 'name';
  static const descriptionField = 'description';

  final String name;
  final String? description;

  const Exercise({int? id, required this.name, this.description})
      : super(id: id);

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

  Exercise copyWith({int? id, String? name, String? description}) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }

  @override
  String toString() {
    return toJson().toString();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is Exercise &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          description == other.description;

  @override
  int get hashCode => super.hashCode ^ name.hashCode ^ description.hashCode;
}
