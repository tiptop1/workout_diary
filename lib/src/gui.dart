import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Route {
  static const init = '/init';
  static const allWorkouts = '/allWorkouts';
  static const allExercises = '/allExercises';
}

class WorkoutDiaryWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      onGenerateTitle: (BuildContext ctx) => AppLocalizations.of(ctx)!.appTitle,
      initialRoute: Route.init,
      routes: {
        Route.init: (context) => _initialWidget(context),
        Route.allWorkouts: (context) => AllWorkoutsWidget(),
        Route.allExercises: (context) => AllExercisesWidget(),
      },
    );
  }
}

Widget _initialWidget(BuildContext context) {
  var tabs = {
    AppLocalizations.of(context)!.workoutsTab: AllWorkoutsWidget(),
    AppLocalizations.of(context)!.exercisesTab: AllExercisesWidget(),
  } as LinkedHashMap;

  return DefaultTabController(
    length: tabs.length,
    child: Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          tabs: [...tabs.keys.map((e) => Tab(text: e))],
        ),
        title: Text(AppLocalizations.of(context)!.appTitle),
      ),
      body: TabBarView(
        children: [...tabs.values],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your onPressed code here!
        },
        child: const Icon(Icons.add),
      ),
    ),
  );
}

class AllWorkoutsWidget extends StatelessWidget {
  Widget build(BuildContext context) => Text('$this - implement it!');
}

class AllExercisesWidget extends StatelessWidget {
  Widget build(BuildContext context) => Text('$this - implement it!');
}
