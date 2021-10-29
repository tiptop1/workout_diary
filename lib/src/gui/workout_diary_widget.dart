import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'all_exercises_tab_widget.dart';
import 'all_workouts_tab_widget.dart';

class Route {
  static const allWorkouts = '/allWorkouts';
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
      initialRoute: Route.allWorkouts,
      routes: {
        Route.allWorkouts: (context) => _buildAllWorkoutsTabWidget(context),
      },
    );
  }
}

Widget _buildAllWorkoutsTabWidget(BuildContext context) {
  var tabs = {
    AppLocalizations.of(context)!.workoutsTab: AllWorkoutsTabWidget(),
    AppLocalizations.of(context)!.exercisesTab: AllExercisesTabWidget(),
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

