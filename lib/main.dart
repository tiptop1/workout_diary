import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:logging/logging.dart';

import 'injection_container.dart';
import 'src/presentation/routes/main_route.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Logging configuration
  Logger.root.level = Level.WARNING;

  await init();

  runApp(MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: ThemeData.light(),
    darkTheme: ThemeData.dark(),
    onGenerateTitle: (BuildContext ctx) => AppLocalizations.of(ctx)!.appTitle,
    home: const MainRoute(),
  ));
}
