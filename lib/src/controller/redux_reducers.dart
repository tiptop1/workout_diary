import 'package:redux/redux.dart';
import 'package:workout_diary/src/controller/redux_actions.dart';
import 'package:workout_diary/src/model/app_state.dart';

typedef AppStateReducer = AppState Function(AppState state, dynamic action);

AppStateReducer createReducer() {
  return combineReducers<AppState>([
    TypedReducer<AppState, LoadExercisesAction>((state, action) =>
        action.exercises != null
            ? AppState(exercises: action.exercises!, workouts: state.workouts)
            : state),
    TypedReducer<AppState, LoadWorkoutsAction>((state, action) =>
        action.workouts != null
            ? AppState(exercises: state.exercises, workouts: action.workouts!)
            : state),
    TypedReducer<AppState, AddExerciseAction>(_addExerciseReducer),
    TypedReducer<AppState, AddWorkoutAction>(_addWorkoutReducer),
    TypedReducer<AppState, ModifyExerciseAction>(_modifyExerciseReducer),
    TypedReducer<AppState, ModifyWorkoutAction>(_modifyWorkoutReducer),
    TypedReducer<AppState, RemoveExerciseAction>(_removeExerciseReducer),
    TypedReducer<AppState, RemoveWorkoutAction>(_removeWorkoutReducer),
  ]);
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
    newState = AppState(exercises: state.exercises, workouts: [...state.workouts, addedWorkout!]..sort((w1, w2) => w1.id! - w2.id!));
  } else {
    newState = state;
  }
  return newState;
}