abstract class Entity {
  static const idField = 'id';

  final int? id;

  const Entity({this.id});

  Entity.fromJson(Map<String, dynamic> json) : id = json[idField];

  Map<String, dynamic> toJson() => {idField: id};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Entity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
