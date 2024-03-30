import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:workout_diary/src/presentation/bloc/workout_diary_states.dart';
import 'package:workout_diary/src/presentation/routes/workouts_tab_content.dart';
import 'package:workout_diary/src/presentation/widgets/progress_indicator.dart';

import '../bloc/main_route_bloc.dart';
import 'exercise_route.dart';
import 'exercises_tab_content.dart';

class MainRoute extends StatefulWidget {
  const MainRoute({super.key});

  @override
  State<MainRoute> createState() => _MainRouteState();
}

class _MainRouteState extends State<MainRoute>
    with SingleTickerProviderStateMixin {
  
  late TabController _tabController;


  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      vsync: this,
      length: 2,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (_) => MainRouteBloc(
          exerciseUseCases: GetIt.I(), workoutUseCases: GetIt.I()),
      child: Scaffold(
        appBar: AppBar(
          title: Text(loc.appTitle),
          bottom: TabBar(controller: _tabController, tabs: [
              Tab(
                text: loc.workoutsTab,
              ),
            Tab(
              text: loc.exercisesTab,
            )
          ]),
        ),
        body: BlocBuilder<MainRouteBloc, WorkoutDiaryState>(
            builder: (context, state) {
          if (state is MainRouteState) {
            var exercises = state.exercises;
            if (exercises.isEmpty) {
              _tabController.index = 2;
            }
            return TabBarView(
              controller: _tabController,
              children: [
                WorkoutsTabContent(workouts: state.workouts),
                ExercisesTabContent(exercises: exercises),
              ],
            );
          } else if (state is ProgressIndicatorState) {
            return const ProgressIndicatorWidget();
          } else {
            // TODO: Add widget to handle errors
            return const Placeholder();
          }
        }),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            var tabIndex = _tabController.index;
            Widget route;
            if (tabIndex == 2) {
              route = ExerciseRoute(key: UniqueKey(), modifiable: true,);
            } else {
              route = WorkoutRoute(key: UniqueKey(), modifiable: true,);
            }
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => route))
                .then((event) {
              if (event != null) {
                BlocProvider.of<MainRouteBloc>(context).add(event);
              }
            });
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
