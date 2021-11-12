import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../domain.dart';
import '../repository.dart';
import 'progress_widget.dart';

class AddExerciseWidget extends StatefulWidget {
  @override
  State<AddExerciseWidget> createState() => _AddExerciseWidgetState();
}

class _AddExerciseWidgetState extends State<AddExerciseWidget> {
  Exercise? _exercise;

  TextEditingController? _nameTextController;
  TextEditingController? _descriptionTextController;

  @override
  void dispose() {
    _nameTextController?.dispose();
    _descriptionTextController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var widget;
    if (_exercise == null) {
      widget = _createExerciseForm(context);
    } else {
      widget = ProgressWidget();
    }
    return widget;
  }

  Widget _createExerciseForm(BuildContext context) {
    var appLocalizations = AppLocalizations.of(context)!;
    _nameTextController = TextEditingController();
    _descriptionTextController = TextEditingController();

    var nameTextField = TextField(
      controller: _nameTextController,
      decoration: InputDecoration(
          labelText: appLocalizations.exerciseName,
          border: OutlineInputBorder(),
          hintText: appLocalizations.exerciseNameHint),
    );

    var descriptionTextField = TextField(
      controller: _descriptionTextController,
      decoration: InputDecoration(
          labelText: appLocalizations.exerciseDescription,
          border: OutlineInputBorder(),
          hintText: appLocalizations.exerciseDescriptionHint),
    );

    return Scaffold(
        appBar: AppBar(
          title: Text(appLocalizations.addExerciseTitle),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                _onPressedBack(context);
              }),
        ),
        body: Column(
          children: [
            SizedBox(height: 10),
            nameTextField,
            SizedBox(height: 10),
            descriptionTextField,
          ],
        ));
  }

  void _onPressedBack(BuildContext context) {
    var exerciseName = _nameTextController?.value.text;
    var exerciseDescription = _descriptionTextController?.value.text;
    if (exerciseName == null || exerciseName == '') {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.exerciseEmptyNameWarning),
      ));
      // New exercise not added, so return false
      Navigator.pop(context, false);
    } else {
      var exercise = Exercise(
        name: exerciseName,
        description: exerciseDescription,
      );
      Repository.of(context)
          .insertExercise(exercise)
          .then((Exercise ex) => Navigator.pop(context, true));
      setState(() => _exercise = exercise);
    }
  }
}
