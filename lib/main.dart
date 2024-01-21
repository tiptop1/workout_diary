import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:logging/logging.dart';

import 'src/presentation/routes/main_route.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Logging configuration
  Logger.root.level = Level.WARNING;

  runApp(MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: ThemeData.light(),
    darkTheme: ThemeData.dark(),
    onGenerateTitle: (BuildContext ctx) => AppLocalizations.of(ctx)!.appTitle,
    home: const MainRoute(),
  ));
}
