import 'package:equatable/equatable.dart';

class Exercise extends Equatable {
  final String name;
  final String? description;

  const Exercise({required this.name, this.description});

  @override
  List<Object> get props => [name];

  @override
  bool get stringify => true;
}