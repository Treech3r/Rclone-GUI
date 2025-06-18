enum RemoteCreationInputType {
  text,
  password,
  boolean,
  dropdown,
  number,
}

class RemoteCreationInput {
  final String key;
  final String label;
  final RemoteCreationInputType type;
  final bool required;
  final String? defaultValue;
  final List<String>? options;
  final String? hint;

  RemoteCreationInput({
    required this.key,
    required this.label,
    required this.type,
    this.required = false,
    this.defaultValue,
    this.options,
    this.hint,
  });
}
