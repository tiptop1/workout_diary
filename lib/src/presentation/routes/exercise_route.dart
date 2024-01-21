import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../domain/entity/exercise.dart';

class ExerciseRoute extends StatefulWidget {
  final bool modifiable;
  final Exercise? exercise;

  const ExerciseRoute({super.key, this.exercise, this.modifiable = false});

  @override
  State<ExerciseRoute> createState() => _ExerciseRouteState();
}

class _ExerciseRouteState extends State<ExerciseRoute> {
  static const int nameMaxLength = 100;
  static const int descriptionMaxLength = 500;

  late final TextEditingController _nameTextController;
  late final TextEditingController _descriptionTextController;
  late final GlobalKey<FormState> _formKey;

  @override
  void initState() {
    super.initState();
    _nameTextController =
        TextEditingController(text: widget.exercise?.name ?? '');
    _descriptionTextController =
        TextEditingController(text: widget.exercise?.description ?? '');
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
    var addExercise = widget.exercise == null;
    var appLocalizations = AppLocalizations.of(context)!;

    var nameTextField = _createTextFormField(
      modifiable: widget.modifiable,
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
        modifiable: widget.modifiable,
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
          title: Text(_calculateTitle(
              appLocalizations, widget.modifiable, addExercise)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _backButtonCallback(context),
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () =>
                  _saveButtonCallback(context, widget.modifiable, addExercise),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 10),
              nameTextField,
              if (widget.modifiable ||
                  _descriptionTextController.text.isNotEmpty)
                const SizedBox(height: 10),
              if (widget.modifiable ||
                  _descriptionTextController.text.isNotEmpty)
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
    Navigator.pop(context);
  }

  void _addExerciseCallback(BuildContext context) {
    var name = _nameTextController.value.text;
    var description = _descriptionTextController.value.text;
    Navigator.pop(context, (
      name: name,
      description: (description.trim().isNotEmpty ? description : null),
    ));
  }

  void _modifyExerciseCallback(BuildContext context) {
    var modifiedName = _nameTextController.value.text;
    var modifiedDescription = _descriptionTextController.value.text;

    if (modifiedName == '') {
      // exercise_db_entity.dart not modified, so return false
      Navigator.pop(context, null);
    } else if (modifiedName == widget.exercise?.name &&
        modifiedDescription == widget.exercise?.description) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.exerciseNotModifiedWarning),
      ));
      Navigator.pop(context);
    } else {
      var modifiedExercise = Exercise(
        id: widget.exercise!.id,
        name: modifiedName,
        description:
            modifiedDescription.trim() == '' ? null : modifiedDescription,
      );
      Navigator.pop(context, modifiedExercise);
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
