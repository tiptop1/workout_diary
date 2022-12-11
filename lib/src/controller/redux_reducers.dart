import 'package:redux/redux.dart';
import 'package:workout_diary/src/controller/redux_actions.dart';
import 'package:workout_diary/src/model/app_state.dart';

typedef AppStateReducer = AppState Function(AppState state, dynamic action);

AppStateReducer createReducer() {
  return combineReducers<AppState>([
    TypedReducer<AppState, LoadExercisesAction>(_loadExercisesReducer),
    TypedReducer<AppState, LoadWorkoutsAction>(_loadWorkoutsReducer),
    TypedReducer<AppState, AddExerciseAction>(_addExerciseReducer),
    TypedReducer<AppState, AddWorkoutAction>(_addWorkoutReducer),
    TypedReducer<AppState, ModifyExerciseAction>(_modifyExerciseReducer),
    TypedReducer<AppState, ModifyWorkoutAction>(_modifyWorkoutReducer),
    TypedReducer<AppState, RemoveExerciseAction>(_removeExerciseReducer),
    TypedReducer<AppState, RemoveWorkoutAction>(_removeWorkoutReducer),
  ]);
}

AppState _loadExercisesReducer(AppState state, LoadExercisesAction action) {
  return AppState(exercises: action.exercises ?? [], workouts: state.workouts);
}

AppState _loadWorkoutsReducer(AppState state, LoadWorkoutsAction action) {
  return AppState(exercises: state.exercises, workouts: action.workouts ?? []);
}

AppState _addExerciseReducer(AppState state, AddExerciseAction action) {
  var addedExercise = action.exercise;
  var newState;
  if (addedExercise != null) {
    newState = AppState(
        exercises: [...state.exercises, addedExercise]
          ..sort((e1, e2) => e1.name.compareTo(e2.name)),
        workouts: state.workouts);
  } else {
    newState = state;
  }
  return newState;
}

AppState _addWorkoutReducer(AppState state, AddWorkoutAction action) {
  var addedWorkout = action.workout;
  var newState;
  if (addedWorkout?.id != null) {
    newState = AppState(
        exercises: state.exercises,
        workouts: [...state.workouts, addedWorkout!]
          ..sort((w1, w2) => w1.id! - w2.id!));
  } else {
    newState = state;
  }
  return newState;
}

AppState _modifyExerciseReducer(AppState state, ModifyExerciseAction action) {
  var modifiedExercise = action.exercise;
  var prevExercises = state.exercises;
  return AppState(
      exercises: List.generate(
          prevExercises.length,
          (i) => prevExercises[i].id == modifiedExercise.id
              ? modifiedExercise
              : prevExercises[i]),
      workouts: state.workouts);
}

AppState _modifyWorkoutReducer(AppState state, ModifyWorkoutAction action) {
  var modifiedWorkout = action.workout;
  var prevWorkouts = state.workouts;
  return AppState(
      exercises: state.exercises,
      workouts: List.generate(
          prevWorkouts.length,
          (i) => prevWorkouts[i].id == modifiedWorkout.id
              ? modifiedWorkout
              : prevWorkouts[i]));
}

AppState _removeExerciseReducer(AppState state, RemoveExerciseAction action) {
  return AppState(
      exercises:
          state.exercises.where((ex) => ex.id != action.exerciseId).toList(),
      workouts: state.workouts);
}

AppState _removeWorkoutReducer(AppState state, RemoveWorkoutAction action) {
  return AppState(
      exercises: state.exercises,
      workouts:
          state.workouts.where((wr) => wr.id != action.workoutId).toList());
}
