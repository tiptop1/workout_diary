import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../old_controller/redux_reducers.dart';
import '../old_controller/redux_middleware.dart';
import '../old_controller/repository.dart';
import '../old_model/app_state.dart';
import 'progress_widget.dart';

class ReduxStoreInitWidget extends StatefulWidget {
  final Widget child;

  const ReduxStoreInitWidget({Key? key, required this.child}) : super(key: key);

  @override
  State<ReduxStoreInitWidget> createState() => _ReduxStoreInitWidgetState();
}

class _ReduxStoreInitWidgetState extends State<ReduxStoreInitWidget> {
  Repository? _repo;
  Store<AppState>? _store;


  @override
  void dispose() {
    _repo?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_store == null) {
      Repository.init().then((repository) {
        _repo = repository;
        return _createStore(_repo!);
      }).then((store) {
        _store = store;
        setState(() {});
      });
      return const ProgressWidget();
    } else {
      return StoreProvider(store: _store!, child: widget.child);
    }
  }

  Future<Store<AppState>> _createStore(Repository repo) async {
    var exercises = await repo.findAllExercises();
    var workouts = await repo.findAllWorkouts(exercises);
    return Store(createReducer(),
        initialState: AppState(
          exercises: exercises,
          workouts: workouts,
        ),
        middleware: createMiddleware(repo));
  }
}
