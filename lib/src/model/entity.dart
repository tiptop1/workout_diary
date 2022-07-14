abstract class Entity {
  static const idField = 'id';

  final int? id;

  const Entity({this.id});

  Entity.fromJson(Map<String, dynamic> json) : id = json[idField];

  Map<String, dynamic> toJson() => {idField: id};
}
