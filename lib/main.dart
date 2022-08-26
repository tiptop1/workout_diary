import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:workout_diary/src/gui/progress_widget.dart';
import 'package:workout_diary/src/gui/workout_diary_widget.dart';

import 'src/model/repository.dart';

void main() {
  GetIt.I.registerSingletonAsync<Repository>(
    () async => Repository.init(),
    // TODO: Make sure, that GetIt dispose method is run implicit after application finish
    dispose: (repository) => repository.dispose(),
  );

  runApp(MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: ThemeData.light(),
    darkTheme: ThemeData.dark(),
    onGenerateTitle: (BuildContext ctx) => AppLocalizations.of(ctx)!.appTitle,
    home: buildWidget(),
  ));
}

Widget buildWidget() {
  return FutureBuilder(
    future: GetIt.I.allReady(),
    builder: (BuildContext context, AsyncSnapshot snapshot) {
      return snapshot.hasData ? WorkoutDiaryWidget() : ProgressWidget();
    },
  );
}
