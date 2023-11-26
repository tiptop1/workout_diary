import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../old_model/app_state.dart';
import '../old_model/exercise.dart';
import 'exercise_widget.dart';
import 'exercises_tab_widget.dart';
import 'workout_widgets.dart';
import 'workouts_tab_widget.dart';

class WorkoutDiaryWidget extends StatefulWidget {
  const WorkoutDiaryWidget({Key? key}) : super(key: key);

  @override
  State<WorkoutDiaryWidget> createState() => _WorkoutDiaryWidgetState();
}

class _WorkoutDiaryWidgetState extends State<WorkoutDiaryWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
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
      appLocalizations.workoutsTab: WorkoutsTabWidget(key: UniqueKey()),
      appLocalizations.exercisesTab: ExercisesTabWidget(key: UniqueKey()),
    } as LinkedHashMap<String, Widget>;

    return StoreConnector<AppState, List<Exercise>>(
      onInitialBuild: (exercises) => _tabController.index = exercises.isEmpty
          ? _findIndex(tabs, appLocalizations.exercisesTab)
          : 0,
      onWillChange: (prevExercises, exercises) {
        if (exercises.isEmpty) {
          _tabController.index =
              _findIndex(tabs, appLocalizations.exercisesTab);
        }
      },
      converter: (store) => store.state.exercises,
      builder: (context, exercises) {
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
              var currentTab = tabs.keys.elementAt(_tabController.index);
              Widget tabWidget;
              if (currentTab == appLocalizations.exercisesTab) {
                tabWidget = ExerciseWidget(key: UniqueKey(), modifiable: true,);
              } else {
                tabWidget = WorkoutWidget(key: UniqueKey(), modifiable: true,);
              }
              Navigator.push(context,
                      MaterialPageRoute(builder: (context) => tabWidget))
                  .then((action) {
                if (action != null) {
                  StoreProvider.of<AppState>(context).dispatch(action);
                }
              });
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  /// Find index of given [key] - make sense only for ordered [map]'s.
  int _findIndex(LinkedHashMap<String, dynamic> map, String key) {
    var i = 0;
    var indexFound = false;
    for (var k in map.keys) {
      if (k == key) {
        indexFound = true;
        break;
      }
      i++;
    }
    return indexFound ? i : 0;
  }
}
