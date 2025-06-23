import 'package:flutter/widgets.dart';

enum RemoteCreationInputType {
  text,
  password,
  boolean,
  dropdown,
  number,
}

class RemoteCreationTextInput {
  final String key;
  final String label;
  final RemoteCreationInputType type;
  final bool required;
  final String? defaultValue;
  final Map<String, String>? options;
  final String? hint;
  final IconData? prefixIcon;

  RemoteCreationTextInput({
    required this.key,
    required this.label,
    required this.type,
    this.required = false,
    this.defaultValue,
    this.options,
    this.hint,
    this.prefixIcon,
  });
}
