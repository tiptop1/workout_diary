import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../domain.dart';
import '../repository.dart';
import 'progress_widget.dart';

class ExerciseWidget extends StatefulWidget {
  final bool _modifiable;
  final int? _exerciseId;

  ExerciseWidget({Key? key, int? exerciseId, bool modifiable = false})
      : _modifiable = modifiable,
        _exerciseId = exerciseId,
        super(key: key);

  @override
  State<ExerciseWidget> createState() => ExerciseWidgetState();
}

class ExerciseWidgetState extends State<ExerciseWidget> {
  Exercise? _exercise;
  late final TextEditingController _nameTextController;
  late final TextEditingController _descriptionTextController;

  @override
  void initState() {
    super.initState();
    _nameTextController = TextEditingController();
    _descriptionTextController = TextEditingController();
  }

  @override
  void dispose() {
    _descriptionTextController.dispose();
    _nameTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget? buildWidget;
    var exerciseId = widget._exerciseId;
    if (exerciseId != null) {
      // Exercise is already created and in database - show or modify it.
      if (_exercise == null) {
        // Load already existed exercise from database.
        Repository.of(context).findExerciseDetails(exerciseId).then((e) {
          setState(() {
            _exercise = e;
          });
        }).catchError((err) {
          log('Can not load exercise (id: $exerciseId) from database.');
        });
        // Until load will complete show progress widget.
        buildWidget = ProgressWidget();
      } else {
        // Exercise is already loaded from database,
        // so initiate text controllers with values from the exercise.
        _nameTextController.text = _exercise!.name;
        var exerciseDescr = _exercise!.description;
        if (exerciseDescr != null) {
          _descriptionTextController.text = exerciseDescr;
        }
      }
    }
    return buildWidget ??
        buildExerciseWidget(context, _nameTextController,
            _descriptionTextController, widget._modifiable, exerciseId == null);
  }

  Widget buildExerciseWidget(
      BuildContext context,
      TextEditingController nameTextController,
      TextEditingController descriptionTextController,
      bool modifiable,
      bool addExercise) {
    var appLocalizations = AppLocalizations.of(context)!;

    var nameTextField = TextField(
      enabled: modifiable,
      controller: _nameTextController,
      decoration: InputDecoration(
          labelText: appLocalizations.exerciseName,
          border: OutlineInputBorder(),
          hintText: appLocalizations.exerciseNameHint),
    );

    var descriptionTextField = TextField(
      enabled: modifiable,
      controller: _descriptionTextController,
      decoration: InputDecoration(
          labelText: appLocalizations.exerciseDescription,
          border: OutlineInputBorder(),
          hintText: appLocalizations.exerciseDescriptionHint),
    );

    return Scaffold(
        appBar: AppBar(
          title:
              Text(_calculateTitle(appLocalizations, modifiable, addExercise)),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                backButtonCallback(context, modifiable, addExercise);
              }),
        ),
        body: Column(
          children: [
            SizedBox(height: 10),
            nameTextField,
            if (modifiable || descriptionTextController.text.isNotEmpty)
              SizedBox(height: 10),
            if (modifiable || descriptionTextController.text.isNotEmpty)
              descriptionTextField,
          ],
        ));
  }

  bool shouldAddExercise(bool modifiable, bool addExercise) =>
      modifiable && addExercise;

  bool shouldModifyExercise(bool modifiable, bool addExercise) =>
      modifiable && !addExercise;

  String _calculateTitle(
      AppLocalizations appLocalizations, bool modifiable, bool addExercise) {
    var title;
    if (shouldAddExercise(modifiable, addExercise)) {
      // Add new exercise
      title = appLocalizations.addExerciseTitle;
    } else if (shouldModifyExercise(modifiable, addExercise)) {
      // Modify already existed exercise
      title = appLocalizations.modifyExerciseTitle;
    } else {
      // Just show (without modification) exercise
      title = appLocalizations.showExerciseTitle;
    }
    return title;
  }

  void backButtonCallback(
      BuildContext context, bool modifiable, bool addExercise) {
    if (shouldAddExercise(modifiable, addExercise)) {
      // Add new exercise
      addExerciseCallback(context);
    } else if (modifiable && !addExercise) {
      // Modify already existed exercise
      modifyExerciseCallback(context);
    } else {
      // Just show (without modification) exercise
      showExerciseCallback(context);
    }
  }

  void addExerciseCallback(BuildContext context) {
    var exerciseName = _nameTextController.value.text;
    var exerciseDescription = _descriptionTextController.value.text;
    if (exerciseName == '') {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.exerciseEmptyNameWarning),
      ));
      // New exercise not added, so return false
      Navigator.pop(context, false);
    } else {
      var exercise = Exercise(
        name: exerciseName,
        description: (exerciseDescription.trim().length > 0
            ? exerciseDescription
            : null),
      );
      Repository.of(context)
          .insertExercise(exercise)
          .then((Exercise ex) => Navigator.pop(context, true))
          .catchError((error) {
        log("Can not add new exercise. Error: $error.");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context)!.exerciseEmptyNameWarning),
        ));
      });
    }
  }

  void modifyExerciseCallback(BuildContext context) {
    var modifiedName = _nameTextController.value.text;
    var modifiedDescription = _descriptionTextController.value.text;

    if (modifiedName == '') {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.exerciseEmptyNameWarning),
      ));
      // Exercise not modified, so return false
      Navigator.pop(context, false);
    } else if (modifiedName == _exercise!.name &&
        modifiedDescription == _exercise!.description) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.exerciseNotModifiedWarning),
      ));
      // Exercise not modified, so return false
      Navigator.pop(context, false);
    } else {
      var modifiedExercise = Exercise(
        id: _exercise!.id,
        name: modifiedName,
        description:
            (modifiedDescription.trim() == '' ? null : modifiedDescription),
      );
      Repository.of(context)
          .updateExercise(modifiedExercise)
          .then((Exercise? ex) {
        assert(
            ex != null, "Exercise with id:${modifiedExercise.id} not updated.");
        Navigator.pop(context, true);
      });
    }
  }

  void showExerciseCallback(BuildContext context) =>
      Navigator.pop(context, false);
}
