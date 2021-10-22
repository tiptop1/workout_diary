import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class Validator<T> {
  String? validate(T? value);
}

/// Converts {strValue} from String type to desired one.
/// Useful to set parameter value from UI form.
abstract class Converter<T> {
  T? convert(String? strValue);
}

class BoolConverter extends Converter<bool> {
  @override
  bool convert(String? strValue) =>
      (strValue?.toLowerCase() == 'true' ? true : false);
}

class ParamGroupDefinition {
  static const String groupSeparator = '.';
  final String name;
  final int order;
  final List<ParamDefinition> children;

  ParamGroupDefinition(this.name, this.order, List<ParamDefinition> children)
      : this.children = List.unmodifiable(children) {
    children.forEach((ch) => ch.group = this);
  }
}

abstract class ParamDefinition<T> {
  final String name;
  final int order;
  final T _defaultValue;
  ParamGroupDefinition? group;

  get defaultValue => _defaultValue;
  final Converter<T>? converter;
  final List<Validator<T>> validators;

  ParamDefinition(this.name, this.order, this._defaultValue,
      {this.group, this.converter, List<Validator<T>> validators = const []})
      : this.validators = List.unmodifiable(validators);

  String qualifiedName() {
    var qualifiedName;
    if (group != null) {
      qualifiedName =
          '${group!.name}${ParamGroupDefinition.groupSeparator}$name';
    } else {
      qualifiedName = name;
    }
    return qualifiedName;
  }

  String? validate(T newValue) {
    var validationMsg;
    for (var validator in validators) {
      validationMsg = validator.validate(newValue);
      if (validationMsg != null) {
        break;
      }
    }

    return validationMsg;
  }
}

class BoolParamDefinition extends ParamDefinition<bool> {
  BoolParamDefinition(String name, int order, bool defaultValue,
      {ParamGroupDefinition? group,
      Converter<bool>? converter,
      List<Validator<bool>> validators = const []})
      : super(name, order, defaultValue,
            group: group, converter: converter, validators: validators);
}

class IntParamDefinition extends ParamDefinition<int> {
  IntParamDefinition(String name, int order, int defaultValue,
      {ParamGroupDefinition? group,
      Converter<int>? converter,
      List<Validator<int>> validators = const []})
      : super(name, order, defaultValue,
            group: group, converter: converter, validators: validators);
}

class Configuration extends InheritedWidget {
  final SharedPreferences _sharedPreferences;
  final Map<String, dynamic> _parameters = {};
  get parameters => Map.unmodifiable(_parameters);
  final Map<String, ParamGroupDefinition> _definitions = {};
  get definitions => Map.unmodifiable(_definitions);

  Configuration({Key? key, required SharedPreferences sharedPreferences, required Widget child})
      : _sharedPreferences = sharedPreferences, super(key: key, child: child) {
    Map<String, ParamDefinition> paramDefs = {};
    _definitions.forEach((groupName, groupDef) => groupDef.children
        .forEach((paramDef) => paramDefs[paramDef.qualifiedName()] = paramDef));

    // Load into configuration parameters from SharedPreferences.
    for (var k in _sharedPreferences.getKeys()) {
      var loadedValue = _sharedPreferences.get(k);
      if (paramDefs.containsKey(k)) {
        // Check value of loaded parameter - if definition exist,
        // but value isn't valid, then set default value
        var paramDef = paramDefs[k];
        if (paramDef!.validate(loadedValue) == null) {
          // TODO: Check type of loaded value - it should be compliant with definition.
          _parameters[k] = loadedValue;
        } else {
          _parameters[k] = paramDef.defaultValue;
        }
      } else {
        _parameters[k] = loadedValue;
      }
    }

    // Add default values for parameters not loaded yet
    for (var k in paramDefs.keys) {
      if (!_parameters.containsKey(k)) {
        _parameters[k] = paramDefs[k]!.defaultValue;
      }
    }

  }

  Future<void> store() async {
    _parameters.forEach((name, value) {
      if (value is int) {
        _sharedPreferences.setInt(name, value);
      } else if (value is double) {
        _sharedPreferences.setDouble(name, value);
      } else if (value is bool) {
        _sharedPreferences.setBool(name, value);
      } else if (value is String) {
        _sharedPreferences.setString(name, value);
      } else {
        throw Exception(
            'Parameter of name $name has unsupported type ${value?.runtimeType}.');
      }
    });
  }

  static Configuration of(BuildContext context) {
    final Configuration? result =
        context.dependOnInheritedWidgetOfExactType<Configuration>();
    assert(result != null, 'No Configuration found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(Configuration oldConfig) => false;
}
