import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../model/repository.dart';
import 'progress_widget.dart';

class ReduxStoreInitWidget extends StatefulWidget {
  final Widget child;

  const ReduxStoreInitWidget({ required this.child, Key? key}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(future: _repo, builder: (BuildContext context, AsyncSnapshot<Repository> snapshot) {
      if (snapshot.hasData) {
        var repo = snapshot.data!;
        return StoreProvider(store: _createStore(_repo), child: widget.child);
      } else {
        return ProgressWidget();
      }
    });
  }
}
