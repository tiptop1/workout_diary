import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../domain.dart';
import '../repository.dart';
import 'progress_widget.dart';

mixin ExerciseMixin {
  late final TextEditingController _nameTextController;
  late final TextEditingController _descriptionTextController;

  void initTextControllers() {
    _nameTextController = TextEditingController();
    _descriptionTextController = TextEditingController();
  }

  void disposeTextControllers() {
    _descriptionTextController.dispose();
    _nameTextController.dispose();
  }

  Widget buildExerciseWidget(BuildContext context, String title,
      {String? initName, String? initDescription, bool editable = false}) {
    if (initName != null) {
      _nameTextController.text = initName;
    }

    if (initDescription != null) {
      _descriptionTextController.text = initDescription;
    }

    var appLocalizations = AppLocalizations.of(context)!;

    var nameTextField = TextField(
      enabled: editable,
      controller: _nameTextController,
      decoration: InputDecoration(
          labelText: appLocalizations.exerciseName,
          border: OutlineInputBorder(),
          hintText: appLocalizations.exerciseNameHint),
    );

    var descriptionTextField = TextField(
      enabled: editable,
      controller: _descriptionTextController,
      decoration: InputDecoration(
          labelText: appLocalizations.exerciseDescription,
          border: OutlineInputBorder(),
          hintText: appLocalizations.exerciseDescriptionHint),
    );

    return Scaffold(
        appBar: AppBar(
          title: Text(title),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                backButtonCallback(context);
              }),
        ),
        body: Column(
          children: [
            SizedBox(height: 10),
            nameTextField,
            if (editable || initDescription != null) SizedBox(height: 10),
            if (editable || initDescription != null) descriptionTextField,
          ],
        ));
  }

  void backButtonCallback(BuildContext context);
}

class AddExerciseWidget extends StatefulWidget {
  AddExerciseWidget({Key? key}) : super(key: key);

  @override
  State<AddExerciseWidget> createState() => AddExerciseState();
}

class AddExerciseState extends State<AddExerciseWidget> with ExerciseMixin {
  Exercise? _exercise;

  @override
  void initState() {
    super.initState();
    initTextControllers();
  }

  @override
  void dispose() {
    disposeTextControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var widget;
    if (_exercise == null) {
      widget = buildExerciseWidget(
          context, AppLocalizations.of(context)!.addExerciseTitle,
          editable: true);
    } else {
      widget = ProgressWidget();
    }
    return widget;
  }

  @override
  void backButtonCallback(BuildContext context) {
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
          .then((Exercise ex) => Navigator.pop(context, true));
      setState(() {
        _exercise = exercise;
      });
    }
  }
}

class ShowExerciseWidget extends StatefulWidget {
  final int exerciseId;

  ShowExerciseWidget({Key? key, required this.exerciseId}) : super(key: key);

  @override
  State<ShowExerciseWidget> createState() => ShowExerciseState();
}

class ShowExerciseState extends State<ShowExerciseWidget> with ExerciseMixin {
  Exercise? _exercise;

  @override
  void initState() {
    super.initState();
    initTextControllers();
  }

  @override
  void dispose() {
    disposeTextControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var newWidget;
    if (_exercise == null) {
      // Load exercise from database
      Repository.of(context)
          .findExerciseDetails(widget.exerciseId)
          .then((exercise) {
        setState(() {
          _exercise = exercise;
        });
      });
      // Progress widget
      newWidget = ProgressWidget();
    } else {
      newWidget = buildExerciseWidget(
          context, AppLocalizations.of(context)!.showExerciseTitle,
          initName: _exercise!.name, initDescription: _exercise!.description);
    }
    return newWidget;
  }

  @override
  void backButtonCallback(BuildContext context) =>
      Navigator.pop(context, false);
}

class ModifyExerciseWidget extends StatefulWidget {
  final int exerciseId;

  ModifyExerciseWidget({Key? key, required this.exerciseId}) : super(key: key);

  @override
  State<ModifyExerciseWidget> createState() => ModifyExerciseState();
}

class ModifyExerciseState extends State<ModifyExerciseWidget>
    with ExerciseMixin {
  Exercise? _currExercise;
  Exercise? _modifiedExercise;

  @override
  void initState() {
    super.initState();
    initTextControllers();
  }

  @override
  void dispose() {
    disposeTextControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var newWidget;
    if (_currExercise == null && _modifiedExercise == null) {
      Repository.of(context)
          .findExerciseDetails(widget.exerciseId)
          .then((exercise) {
        setState(() {
          _currExercise = exercise;
        });
      });
    } else if (_currExercise != null && _modifiedExercise == null) {
      newWidget = buildExerciseWidget(
        context,
        AppLocalizations.of(context)!.modifyExerciseTitle,
        initName: _currExercise!.name,
        initDescription: _currExercise!.description,
        editable: true,
      );
    }

    return (newWidget != null ? newWidget : ProgressWidget());
  }

  @override
  void backButtonCallback(BuildContext context) {
    var modifiedName = _nameTextController.value.text;
    var modifiedDescription = _descriptionTextController.value.text;

    if (modifiedName == '') {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.exerciseEmptyNameWarning),
      ));
      // Exercise not modified, so return false
      Navigator.pop(context, false);
    } else if (modifiedName == _currExercise!.name &&
        modifiedDescription == _currExercise!.description) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.exerciseNotModifiedWarning),
      ));
      // Exercise not modified, so return false
      Navigator.pop(context, false);
    } else {
      var modifiedExercise = Exercise(
        id: _currExercise!.id,
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
      setState(() {
        _modifiedExercise = modifiedExercise;
      });
    }
  }
}
