enum SqliteResultCodes {
  sqliteConstraint(19, 'SQLITE_CONSTRAINT');

  const SqliteResultCodes(this.code, this.name);

  final int code;
  final String name;
}