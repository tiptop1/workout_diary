import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../old_controller/redux_actions.dart';
import '../old_model/exercise.dart';

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
    _nameTextController = TextEditingController(text: widget._exercise?.name ?? '');
    _descriptionTextController = TextEditingController(text: widget._exercise?.description ?? '');
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
    var addExercise = widget._exercise == null;
    var appLocalizations = AppLocalizations.of(context)!;

    var nameTextField = _createTextFormField(
      modifiable: widget._modifiable,
      controller: _nameTextController,
      labelText: appLocalizations.exerciseName,
      hintText: appLocalizations.exerciseNameHint,
      validator: (value) {
        String? msg;
        if (value == null || value.isEmpty) {
          msg = appLocalizations.exerciseNameValidation_required;
        } else if (value.length > nameMaxLength) {
          msg = appLocalizations.exerciseNameValidation_tooLong(nameMaxLength);
        }
        return msg;
      },
    );

    var descriptionTextField = _createTextFormField(
        modifiable: widget._modifiable,
        controller: _descriptionTextController,
        labelText: appLocalizations.exerciseDescription,
        hintText: appLocalizations.exerciseDescriptionHint,
        validator: (value) =>
            value != null && value.length > descriptionMaxLength
                ? appLocalizations
                    .exerciseDescriptionValidation_tooLong(descriptionMaxLength)
                : null);

    return Scaffold(
        appBar: AppBar(
          title:
              Text(_calculateTitle(appLocalizations, widget._modifiable, addExercise)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _backButtonCallback(context),
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () =>
                  _saveButtonCallback(context, widget._modifiable, addExercise),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 10),
              nameTextField,
              if (widget._modifiable || _descriptionTextController.text.isNotEmpty)
                const SizedBox(height: 10),
              if (widget._modifiable || _descriptionTextController.text.isNotEmpty)
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
    String title;
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
        _addExerciseCallback(context);
      } else if (modifiable && !addExercise) {
        // Modify already existed exercise
        _modifyExerciseCallback(context);
      } else {
        // Just show (without modification) exercise
        _showExerciseCallback(context);
      }
    }
  }

  void _backButtonCallback(BuildContext context) {
    Navigator.pop(context, null);
  }

  void _addExerciseCallback(BuildContext context) {
    var exerciseName = _nameTextController.value.text;
    var exerciseDescription = _descriptionTextController.value.text;
    AddExerciseAction? action;
    if (exerciseName != '') {
      action = AddExerciseAction(
        exercise: Exercise(
          name: exerciseName,
          description: (exerciseDescription.trim().isNotEmpty
              ? exerciseDescription
              : null),
        ),
      );
    }
    Navigator.pop(context, action);
  }

  void _modifyExerciseCallback(BuildContext context) {
    var modifiedName = _nameTextController.value.text;
    var modifiedDescription = _descriptionTextController.value.text;

    if (modifiedName == '') {
      // exercise.dart not modified, so return false
      Navigator.pop(context, null);
    } else if (modifiedName == widget._exercise?.name &&
        modifiedDescription == widget._exercise?.description) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.exerciseNotModifiedWarning),
      ));
      // exercise.dart not modified, so return false
      Navigator.pop(context, null);
    } else {
      var action = ModifyExerciseAction(
        exercise: Exercise(
          id: widget._exercise?.id,
          name: modifiedName,
          description:
              modifiedDescription.trim() == '' ? null : modifiedDescription,
        ),
      );
      Navigator.pop(context, action);
    }
  }

  void _showExerciseCallback(BuildContext context) =>
      Navigator.pop(context, null);

  Widget _createTextFormField(
      {required bool modifiable,
      required TextEditingController controller,
      required String labelText,
      required String hintText,
      required FormFieldValidator<String> validator}) {
    return TextFormField(
      enabled: modifiable,
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
        hintText: hintText,
      ),
      validator: validator,
    );
  }
}
