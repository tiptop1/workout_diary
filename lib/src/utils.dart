import 'package:flutter/material.dart';

import 'config.dart';
import 'repository.dart';

mixin NavigatorUtils {
  Future push(BuildContext context, {required Widget child}) {
    var sharedPrefs = Configuration.of(context).sharedPreferences;
    var db = Repository.of(context).database;
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Configuration(
          sharedPreferences: sharedPrefs,
          child: Repository(
            database: db,
            child: child,
          ),
        ),
      ),
    );
  }
}
