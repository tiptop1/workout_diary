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
  String toString() {
    return toJson().toString();
  }
}
