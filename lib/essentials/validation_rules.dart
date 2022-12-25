import 'package:easy_localization/easy_localization.dart';

String validateTextField(Map<Function, List<dynamic>> validationRules) {
  for (Function rule in validationRules.keys) {
    List<dynamic> arguments = validationRules[rule];
    String problem = rule(arguments);
    if (problem != null) {
      return problem;
    }
  }
  return null;
}

//TextField Rules

/// Returns error if String value is empty.
///
/// ```dart
///   value = arguments[0]
/// ```
String isEmpty(List<dynamic> arguments) {
  String value = arguments[0];
  if (value.isEmpty) {
    return 'field_empty'.tr();
  }
  return null;
}

/// Returns error if String value's length is smaller
/// than given length.
///
/// ```dart
///   value = arguments[0]
///   length = arguments[1]
/// ```
String minimalLength(List<dynamic> arguments) {
  String value = arguments[0];
  int length = arguments[1];
  if (value.length < length) {
    return 'minimal_length'.tr(args: [length.toString()]);
  }
  return null;
}

/// Returns error if String value's is not a valid number.
///
///  Optional parameters:
///  * [type] of number.
///  * boolean if the number needs to be greater than 0.
/// ```dart
///   value = arguments[0]
///   type = arguments[1] ?? 'double'
///   needsGreaterZero = arguments[2] ?? true
/// ```
String notValidNumber(List<dynamic> arguments) {
  String value = arguments[0];
  String type = (1 < arguments.length ? arguments[1] : null) ?? 'double';
  bool needsGreaterZero = (2 < arguments.length ? arguments[2] : null) ?? true;
  switch (type) {
    case 'double':
      if (double.tryParse(value) == null) {
        return 'not_valid_num'.tr();
      }
      if (needsGreaterZero && double.parse(value) < 0) {
        return 'not_valid_num'.tr();
      }
      break;
    case 'integer':
      if (int.tryParse(value) == null) {
        return 'not_valid_num'.tr();
      }
      if (needsGreaterZero && int.parse(value) < 0) {
        return 'not_valid_num'.tr();
      }
  }
  return null;
}

/// Returns error if String value doesn't match String otherValue.
///
///  Optional parameters:
///  * [problem] String to print out to the user.
/// ```dart
///   value = arguments[0]
///   otherValue = arguments[1]
///   type = arguments[2] ?? 'password_not_match'
/// ```
String matchString(List<dynamic> arguments) {
  String value = arguments[0];
  String otherValue = arguments[1];
  String problem = (2 < arguments.length ? arguments[2] : null) ?? 'passwords_not_match';
  if (value != otherValue) {
    return problem.tr();
  }
  return null;
}
