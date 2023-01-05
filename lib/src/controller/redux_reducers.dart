import 'package:redux/redux.dart';
import 'package:workout_diary/src/controller/redux_actions.dart';
import 'package:workout_diary/src/model/app_state.dart';
import 'package:workout_diary/src/model/workout.dart';

typedef AppStateReducer = AppState Function(AppState state, dynamic action);

AppStateReducer createReducer() {
  return combineReducers<AppState>([
    TypedReducer<AppState, LoadExercisesAction>(_loadExercisesReducer),
    TypedReducer<AppState, LoadWorkoutsAction>(_loadWorkoutsReducer),
    TypedReducer<AppState, AddExerciseAction>(_addExerciseReducer),
    TypedReducer<AppState, AddWorkoutAction>(_addWorkoutReducer),
    TypedReducer<AppState, ModifyExerciseAction>(_modifyExerciseReducer),
    TypedReducer<AppState, ModifyWorkoutAction>(_modifyWorkoutReducer),
    TypedReducer<AppState, DeleteExerciseAction>(_removeExerciseReducer),
    TypedReducer<AppState, DeleteWorkoutAction>(_removeWorkoutReducer),
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
  return AppState(
      exercises: [...state.exercises, addedExercise]
        ..sort((e1, e2) => e1.name.compareTo(e2.name)),
      workouts: state.workouts);
}

AppState _addWorkoutReducer(AppState state, AddWorkoutAction action) {
  var addedWorkout = action.workout;
  var newState;
  if (addedWorkout.id != null) {
    newState = AppState(
        exercises: state.exercises,
        workouts: [...state.workouts, addedWorkout]
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

AppState _removeExerciseReducer(AppState state, DeleteExerciseAction action) {
  var exerciseId = action.exerciseId;
  return AppState(
      exercises: state.exercises.where((ex) => ex.id != exerciseId).toList(),
      workouts: _removeExerciseSetsByExerciseId(exerciseId, state.workouts));
}

List<Workout> _removeExerciseSetsByExerciseId(
    int exerciseId, List<Workout> workouts) {
  var newWorkouts = <Workout>[];
  for (var workout in workouts) {
    newWorkouts.add(Workout(
        id: workout.id,
        startTime: workout.startTime,
        endTime: workout.endTime,
        title: workout.title,
        preComment: workout.preComment,
        postComment: workout.postComment,
        exerciseSets: workout.exerciseSets
            .where((exSet) => exSet.exercise.id != exerciseId)
            .toList()));
  }
  return newWorkouts;
}

AppState _removeWorkoutReducer(AppState state, DeleteWorkoutAction action) {
  return AppState(
      exercises: state.exercises,
      workouts:
          state.workouts.where((wr) => wr.id != action.workoutId).toList());
}
