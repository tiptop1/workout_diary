import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'all_exercises_tab_widget.dart';
import 'all_workouts_tab_widget.dart';

class WorkoutDiaryWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
}
