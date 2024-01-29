import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:workout_diary/src/domain/use_case/exercise_use_cases.dart';

import '../../domain/use_case/workout_use_cases.dart';
import 'workout_diary_events.dart';
import 'workout_diary_states.dart';

class MainRouteBloc extends Bloc<WorkoutDiaryEvent, WorkoutDiaryState> {
  final ExerciseUseCases exerciseUseCases;
  final WorkoutUseCases workoutUseCases;

  MainRouteBloc({required this.exerciseUseCases, required this.workoutUseCases})
      : super(ProgressIndicatorState()) {
    on<ShowMainRouteEvent>(_onShowMainRoute);
    on<AddExerciseEvent>(_onAddExercise);
    on<ModifyExerciseEvent>(_onModifyExercise);
    on<DeleteExerciseEvent>(_onDeleteExercise);
    on<DeleteWorkoutEvent>(_onDeleteWorkout);
    // Initial event
    add(const ShowMainRouteEvent());
  }

  Future<void> _onShowMainRoute(
      ShowMainRouteEvent event, Emitter<WorkoutDiaryState> emit) async {
    emit(ProgressIndicatorState());
    await _emitMainRouteState(emit);
  }

  Future<void> _onDeleteExercise(
      DeleteExerciseEvent event, Emitter<WorkoutDiaryState> emit) async {
    emit(ProgressIndicatorState());
    (await exerciseUseCases.removeExercise(event.exercise)).fold((failure) {
      emit(ErrorMessageState(failure.code, failure.details, failure.cause));
    }, (_) {});
  }

  Future<void> _onDeleteWorkout(
      DeleteWorkoutEvent event, Emitter<WorkoutDiaryState> emit) async {
    emit(ProgressIndicatorState());
    (await workoutUseCases.removeWorkout(event.workout)).fold((failure) {
      emit(ErrorMessageState(failure.code, failure.details, failure.cause));
    }, (_) {});
  }

  Future<void> _onAddExercise(
      AddExerciseEvent event, Emitter<WorkoutDiaryState> emit) async {
    emit(ProgressIndicatorState());
    (await exerciseUseCases.addExercise(event.name, event.description)).fold(
        (failure) {
      emit(ErrorMessageState(failure.code, failure.details, failure.cause));
    }, (_) async {
      await _emitMainRouteState(emit);
    });
  }

  Future<void> _onModifyExercise(
      ModifyExerciseEvent event, Emitter<WorkoutDiaryState> emit) async {
    emit(ProgressIndicatorState());
    (await exerciseUseCases.modifyExercise(event.exercise)).fold((failure) {
      emit(ErrorMessageState(failure.code, failure.details, failure.cause));
    }, (_) async {
      await _emitMainRouteState(emit);
    });
  }

  Future<void> _emitMainRouteState(Emitter<WorkoutDiaryState> emit) async {
    var exercisesEither = await exerciseUseCases.getAllExercises();
    await exercisesEither.fold(
      (failure) {
        emit(ErrorMessageState(failure.code, failure.details, failure.cause));
      },
      (exercises) async {
        (await workoutUseCases.getAllWorkouts()).fold((failure) {
          emit(ErrorMessageState(failure.code, failure.details, failure.cause));
        }, (workouts) {
          emit(MainRouteState(exercises, workouts));
        });
      },
    );
  }
}
