import 'package:redux/redux.dart';
import 'package:workout_diary/src/model/app_state.dart';

import 'redux_actions.dart';
import 'repository.dart';

List<Middleware<AppState>> createMiddleware(Repository repository) {
  return [
    _loadExercisesMiddleware(repository),
    _loadWorkoutsMiddleware(repository),
    _addExerciseMiddleware(repository),
    _addWorkoutMiddleware(repository),
    _modifyExerciseMiddleware(repository),
    _modifyWorkoutMiddleware(repository),
    _deleteExerciseMiddleware(repository),
    _deleteWorkoutMiddleware(repository),
  ];
}

Middleware<AppState> _loadExercisesMiddleware(Repository repository) {
  return (Store<AppState> store, dynamic action, NextDispatcher next) async {
    if (action is LoadExercisesAction) {
      store.dispatch(LoadExercisesAction(
        exercises: await repository.findAllExercises(),
      ));
    }
    next(action);
  };
}

Middleware<AppState> _loadWorkoutsMiddleware(Repository repository) {
  return (Store<AppState> store, dynamic action, NextDispatcher next) async {
    if (action is LoadWorkoutsAction) {
      var exercises = await repository.findAllExercises();
      store.dispatch(LoadWorkoutsAction(
        workouts: await repository.findAllWorkouts(exercises),
      ));
    }
    next(action);
  };
}

Middleware<AppState> _addExerciseMiddleware(Repository repository) {
  return (Store<AppState> store, dynamic action, NextDispatcher next) async {
    if (action is AddExerciseAction) {
      store.dispatch(AddExerciseAction(
          exercise: await repository.insertExercise(action.exercise)));
    }
    next(action);
  };
}

Middleware<AppState> _addWorkoutMiddleware(Repository repository) {
  return (Store<AppState> store, dynamic action, NextDispatcher next) async {
    if (action is AddWorkoutAction) {
      store.dispatch(AddWorkoutAction(
          workout: await repository.insertWorkout(action.workout)));
    }
    next(action);
  };
}

Middleware<AppState> _modifyExerciseMiddleware(Repository repository) {
  return (Store<AppState> store, dynamic action, NextDispatcher next) async {
    if (action is ModifyExerciseAction) {
      store.dispatch(ModifyExerciseAction(
          exercise: await repository.updateExercise(action.exercise)));
    }
    next(action);
  };
}

Middleware<AppState> _modifyWorkoutMiddleware(Repository repository) {
  return (Store<AppState> store, dynamic action, NextDispatcher next) async {
    if (action is ModifyWorkoutAction) {
      store.dispatch(ModifyWorkoutAction(
          workout: await repository.updateWorkout(action.workout)));
    }
    next(action);
  };
}

Middleware<AppState> _deleteExerciseMiddleware(Repository repository) {
  return (Store<AppState> store, dynamic action, NextDispatcher next) async {
    if (action is DeleteExerciseAction &&
        await repository.deleteExercise(action.exerciseId)) {
      store.dispatch(action);
    }
    next(action);
  };
}

Middleware<AppState> _deleteWorkoutMiddleware(Repository repository) {
  return (Store<AppState> store, dynamic action, NextDispatcher next) async {
    if (action is DeleteWorkoutAction &&
        await repository.deleteWorkout(action.workoutId)) {
      store.dispatch(action);
    }
    next(action);
  };
}
