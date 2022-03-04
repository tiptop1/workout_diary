import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:workout_diary/src/utils.dart';

import 'exercise_widgets.dart';
import 'exercises_tab_widget.dart';
import 'workouts_tab_widget.dart';

class WorkoutDiaryWidget extends StatefulWidget {
  State<WorkoutDiaryWidget> createState() => _WorkoutDiaryWidgetState();
}

class _WorkoutDiaryWidgetState extends State<WorkoutDiaryWidget>
    with SingleTickerProviderStateMixin, NavigatorUtils {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this, length: 2);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appLocalizations = AppLocalizations.of(context)!;
    var tabs = {
      appLocalizations.workoutsTab: AllWorkoutsTabWidget(),
      appLocalizations.exercisesTab: AllExercisesTabWidget(key: UniqueKey()),
    } as LinkedHashMap;

    var currentTab = tabs.keys.elementAt(_tabController.index);
    var tabWidget;
    if (currentTab == appLocalizations.workoutsTab) {
      tabWidget = AllWorkoutsTabWidget();
    } else if (currentTab == appLocalizations.exercisesTab) {
      tabWidget = AddExerciseWidget(key: UniqueKey());
    } else {
      assert(false, 'Tab $currentTab not supported.');
    }

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
            push(context, child: tabWidget).then((result) {
              if (result) {
                setState(() {});
              }
            });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
