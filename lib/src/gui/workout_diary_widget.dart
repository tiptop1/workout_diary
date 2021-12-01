import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../config.dart';
import '../repository.dart';
import 'all_exercises_tab_widget.dart';
import 'all_workouts_tab_widget.dart';
import 'exercise_widgets.dart';

class WorkoutDiaryWidget extends StatefulWidget {
  State<WorkoutDiaryWidget> createState() => _WorkoutDiaryWidgetState();
}

class _WorkoutDiaryWidgetState extends State<WorkoutDiaryWidget>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this, length: 2);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var tabs = {
      AppLocalizations.of(context)!.workoutsTab: AllWorkoutsTabWidget(),
      AppLocalizations.of(context)!.exercisesTab:
          AllExercisesTabWidget(key: UniqueKey()),
    } as LinkedHashMap;

    return Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          controller: _tabController,
          tabs: [...tabs.keys.map((e) => Tab(text: e))],
        ),
        title: Text(AppLocalizations.of(context)!.appTitle),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [...tabs.values],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          SharedPreferences sharedPrefs =
              Configuration.of(context).sharedPreferences;
          Database db = Repository.of(context).database;
          var index = _tabController?.index;
          // TODO: Calculate the indexes
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Configuration(
                  sharedPreferences: sharedPrefs,
                  child: Repository(
                    database: db,
                    child: AddExerciseWidget(key: UniqueKey()),
                  ),
                ),
              ),
            ).then((exerciseAdded) {
              if (exerciseAdded) {
                setState(() {});
              }
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
