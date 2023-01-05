import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../controller/redux_reducers.dart';
import '../controller/redux_middleware.dart';
import '../controller/repository.dart';
import '../model/app_state.dart';
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

  Widget build(BuildContext context) {
    if (_store == null) {
      Repository.init().then((repository) {
        _repo = repository;
        return _createStore(_repo!);
      }).then((store) {
        _store = store;
        setState(() {});
      });
      return ProgressWidget();
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
