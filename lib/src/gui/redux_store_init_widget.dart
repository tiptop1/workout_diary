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

  const ReduxStoreInitWidget({required this.child, Key? key}) : super(key: key);

  @override
  State<ReduxStoreInitWidget> createState() => _ReduxStoreInitWidgetState();
}

class _ReduxStoreInitWidgetState extends State<ReduxStoreInitWidget> {
  late final Future<Repository> _repo;

  @override
  void initState() {
    super.initState();
    _repo = Repository.init();
  }

  @override
  void dispose() {
    _repo.then((repo) => repo.dispose());
    super.dispose();
  }

  // TODO: Refactor it - two FutureBuilders in the same build method - weird!
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _repo,
        builder:
            (BuildContext context, AsyncSnapshot<Repository> repoSnapshot) {
          if (repoSnapshot.hasData) {
            var repo = repoSnapshot.data!;
            var store = _createStore(repo);
            return FutureBuilder(
              future: store,
              builder: (BuildContext context,
                  AsyncSnapshot<Store<AppState>> storeSnapshot) {
                if (storeSnapshot.hasData) {
                  return StoreProvider(
                      store: storeSnapshot.data!, child: widget.child);
                } else {
                  return ProgressWidget();
                }
              },
            );
          } else {
            return ProgressWidget();
          }
        });
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
