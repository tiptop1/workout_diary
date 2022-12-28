import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../controller/redux_actions.dart';
import '../model/app_state.dart';
import '../model/exercise.dart';

class ExerciseWidget extends StatefulWidget {
  final bool _modifiable;
  final Exercise? _exercise;

  const ExerciseWidget({Key? key, Exercise? exercise, bool modifiable = false})
      : _modifiable = modifiable,
        _exercise = exercise,
        super(key: key);

  @override
  State<ExerciseWidget> createState() => _ExerciseWidgetState();
}

class _ExerciseWidgetState extends State<ExerciseWidget> {
  static const int nameMaxLength = 100;
  static const int descriptionMaxLength = 500;

  late final TextEditingController _nameTextController;
  late final TextEditingController _descriptionTextController;
  late final GlobalKey<FormState> _formKey;

  @override
  void initState() {
    super.initState();
    _nameTextController = TextEditingController();
    _descriptionTextController = TextEditingController();
    _formKey = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    _descriptionTextController.dispose();
    _nameTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _nameTextController.text = widget._exercise?.name ?? '';
    _descriptionTextController.text = widget._exercise?.description ?? '';
    return _buildExerciseWidget(
        context,
        _nameTextController,
        _descriptionTextController,
        widget._modifiable,
        widget._exercise == null);
  }

  Widget _buildExerciseWidget(
      BuildContext context,
      TextEditingController nameTextController,
      TextEditingController descriptionTextController,
      bool modifiable,
      bool addExercise) {
    var appLocalizations = AppLocalizations.of(context)!;

    var nameTextField = TextFormField(
      enabled: modifiable,
      controller: _nameTextController,
      decoration: InputDecoration(
          labelText: appLocalizations.exerciseName,
          border: OutlineInputBorder(),
          hintText: appLocalizations.exerciseNameHint),
      validator: (value) {
        var msg;
        if (value == null || value.isEmpty) {
          msg = appLocalizations.exerciseNameValidation_required;
        } else if (value.length > nameMaxLength) {
          msg = appLocalizations.exerciseNameValidation_tooLong(nameMaxLength);
        }
        return msg;
      },
    );

    var descriptionTextField = TextFormField(
      enabled: modifiable,
      controller: _descriptionTextController,
      decoration: InputDecoration(
        labelText: appLocalizations.exerciseDescription,
        border: OutlineInputBorder(),
        hintText: appLocalizations.exerciseDescriptionHint,
      ),
      validator: (value) => value != null && value.length > descriptionMaxLength
          ? appLocalizations
              .exerciseDescriptionValidation_tooLong(descriptionMaxLength)
          : null,
    );

    return Scaffold(
        appBar: AppBar(
          title:
              Text(_calculateTitle(appLocalizations, modifiable, addExercise)),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => _backButtonCallback(context),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.check),
              onPressed: () =>
                  _saveButtonCallback(context, modifiable, addExercise),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 10),
              nameTextField,
              if (modifiable || descriptionTextController.text.isNotEmpty)
                SizedBox(height: 10),
              if (modifiable || descriptionTextController.text.isNotEmpty)
                descriptionTextField,
            ],
          ),
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
      title = appLocalizations.exerciseModifyTitle;
    } else {
      // Just show (without modification) exercise
      title = appLocalizations.exerciseShowTitle;
    }
    return title;
  }

  void _saveButtonCallback(
      BuildContext context, bool modifiable, bool addExercise) {
    if (_formKey.currentState!.validate()) {
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
  }

  void _backButtonCallback(BuildContext context) {
    Navigator.pop(context, false);
  }

  void addExerciseCallback(BuildContext context) {
    var exerciseName = _nameTextController.value.text;
    var exerciseDescription = _descriptionTextController.value.text;
    var exerciseAdded = false;
    if (exerciseName != '') {
      StoreProvider.of<AppState>(context).dispatch(AddExerciseAction(
        exercise: Exercise(
          name: exerciseName,
          description: (exerciseDescription.trim().length > 0
              ? exerciseDescription
              : null),
        ),
      ));
      exerciseAdded = true;
    }
    Navigator.pop(context, exerciseAdded);
  }

  void modifyExerciseCallback(BuildContext context) {
    var modifiedName = _nameTextController.value.text;
    var modifiedDescription = _descriptionTextController.value.text;

    if (modifiedName == '') {
      // Exercise not modified, so return false
      Navigator.pop(context, false);
    } else if (modifiedName == widget._exercise?.name &&
        modifiedDescription == widget._exercise?.description) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.exerciseNotModifiedWarning),
      ));
      // Exercise not modified, so return false
      Navigator.pop(context, false);
    } else {
      StoreProvider.of<AppState>(context).dispatch(ModifyExerciseAction(
        exercise: Exercise(
          id: widget._exercise?.id,
          name: modifiedName,
          description:
              (modifiedDescription.trim() == '' ? null : modifiedDescription),
        ),
      ));
    }
  }

  void showExerciseCallback(BuildContext context) =>
      Navigator.pop(context, false);
}
