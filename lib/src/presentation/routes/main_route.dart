import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:workout_diary/src/presentation/bloc/workout_diary_states.dart';
import 'package:workout_diary/src/presentation/routes/workouts_tab_content.dart';
import 'package:workout_diary/src/presentation/widgets/progress_indicator.dart';

import '../bloc/main_route_bloc.dart';
import 'exercises_tab_content.dart';

class MainRoute extends StatelessWidget {
  const MainRoute({super.key});

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (_) =>
          MainRouteBloc(
              exerciseUseCases: GetIt.I(), workoutUseCases: GetIt.I()),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text(loc.appTitle),
            bottom: TabBar(tabs: [
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
                  return TabBarView(
                    children: [
                      WorkoutsTabContent(workouts: state.workouts),
                      ExercisesTabContent(exercises: state.exercises),
                    ],
                  );
                } else if (state is ProgressIndicatorState) {
                  return const ProgressIndicatorWidget();
                } else {
                  // TODO: Add widget to handle errors
                  return const Placeholder();
                }
              }),
        ),
      ),
    );
  }
}
