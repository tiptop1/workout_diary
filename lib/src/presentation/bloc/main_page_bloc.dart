import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:workout_diary/src/domain/use_case/exercise_use_cases.dart';

import '../../domain/use_case/workout_use_cases.dart';
import 'workout_diary_events.dart';
import 'workout_diary_states.dart';

class MainPageBloc extends Bloc<WorkoutDiaryEvent, WorkoutDiaryState> {
  final ExerciseUseCases exerciseUseCases;
  final WorkoutUseCases workoutUseCases;

  MainPageBloc({required this.exerciseUseCases, required this.workoutUseCases})
      : super(ProgressIndicator()) {
    on<LoadData>(_onLoading);
    on<ShowMainPage>(_onShowMainPage);
    // Initial event
    add(const ShowMainPage());
  }

  void _onLoading(LoadData event, Emitter<WorkoutDiaryState> emit) {
    emit(ProgressIndicator());
  }

  void _onShowMainPage(
      ShowMainPage event, Emitter<WorkoutDiaryState> emit) async {
    emit(ProgressIndicator());
    (await exerciseUseCases.getAllExercises()).fold(
      (failure) {
        emit(ErrorMessage(failure.code, failure.details, failure.cause));
      },
      (exercises) async {
        (await workoutUseCases.getAllWorkouts()).fold((failure) {
          emit(ErrorMessage(failure.code, failure.details, failure.cause));
        }, (workouts) {
          emit(MainPage(exercises, workouts));
        });
      },
    );
  }
}
