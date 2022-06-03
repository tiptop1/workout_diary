import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:workout_diary/src/gui/workout_diary_widget.dart';

import 'src/gui/app_initialization_widget.dart';

void main() {
  // Don't know how, but according to documentation:
  // "Avoid errors caused by flutter upgrade".
  WidgetsFlutterBinding.ensureInitialized();
  runApp(AppInitializationWidget(
      child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          onGenerateTitle: (BuildContext ctx) =>
              AppLocalizations.of(ctx)!.appTitle,
          home: WorkoutDiaryWidget())));
}
