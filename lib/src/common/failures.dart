import 'package:equatable/equatable.dart';

enum FailureCode {
  databaseError;
}

abstract class Failure extends Equatable {
  final FailureCode code;
  final String? details;
  final Object? cause;

  const Failure({required this.code, this.details, this.cause});

  @override
  List<Object> get props => [code];

  @override
  bool get stringify => true;
}

class DatabaseError extends Failure {
  const DatabaseError({String? details, Object? cause}) : super(code: FailureCode.databaseError, details: details, cause: cause);
}
