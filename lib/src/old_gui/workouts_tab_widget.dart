import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import '../old_controller/redux_actions.dart';
import 'list_widget.dart';
import '../old_gui/workout_widgets.dart';

import '../old_model/app_state.dart';
import '../old_model/workout.dart';

/// Implementation of TabListWidget to show list of Workouts
class WorkoutsTabWidget extends ListWidget<Workout> {
  const WorkoutsTabWidget({Key? key}) : super(key: key);

  @override
  List<Workout> storeConnectorConverter(Store<AppState> store) =>
      store.state.workouts;

  @override
  Widget listItemTitle(BuildContext context, Workout entity) {
    var startTime = entity.startTime;
    var startTimeStr = startTime != null
        ? dateTimeStr(Localizations.localeOf(context), startTime)
        : dateLackMarker;

    return Text(
        startTime != null ? '${entity.title} ($startTimeStr)' : entity.title);
  }

  @override
  void listItemModifyAction(BuildContext context, Workout entity) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WorkoutWidget(
            workout: entity,
            modifiable: true,
          ),
        )).then((action) {
          if (action != null) {
            StoreProvider.of<AppState>(context).dispatch(action);
          }
    });
  }

  @override
  void listItemDeleteAction(BuildContext context, Workout entity) {
    assert(entity.id != null, "Deleting workout without id isn't allowed.");
    _showDeleteDialog(context, entity.id!);
  }

  @override
  void listItemShowAction(BuildContext context, Workout entity) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WorkoutWidget(
            workout: entity,
          ),
        ));
  }

  void _showDeleteDialog(BuildContext context, int workoutId) {
    AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return AlertDialog(
            title: Text(appLocalizations.workoutDeleteTitle),
            content: _buildDialogContent(appLocalizations),
            actions: <Widget>[
              TextButton(
                  child: Text(appLocalizations.yes),
                  onPressed: () {
                    StoreProvider.of<AppState>(context)
                        .dispatch(DeleteWorkoutAction(workoutId: workoutId));
                    Navigator.of(context).pop();
                  }),
              TextButton(
                child: Text(appLocalizations.no),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        });
  }

  Widget _buildDialogContent(AppLocalizations appLocalizations) {
    return Row(children: [
      const Expanded(
        flex: 20,
        child: FittedBox(
          fit: BoxFit.fill,
          child: Icon(Icons.help, color: Colors.yellow),
        ),
      ),
      const Spacer(flex: 2),
      Expanded(
        flex: 60,
        child: Text(appLocalizations.workoutDeleteInfo),
      ),
    ]);
  }
}
