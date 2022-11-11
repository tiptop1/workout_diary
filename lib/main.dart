import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:workout_diary/src/gui/redux_store_init_widget.dart';
import 'package:workout_diary/src/gui/workout_diary_widget.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(ReduxStoreInitWidget(
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      onGenerateTitle: (BuildContext ctx) => AppLocalizations.of(ctx)!.appTitle,
      home: WorkoutDiaryWidget(),
    ),
  ));
}
