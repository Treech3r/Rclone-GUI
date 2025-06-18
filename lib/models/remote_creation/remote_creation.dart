import 'remote_creation_step.dart';

typedef RemoteValidator = String? Function(Map<String, String>);

class RemoteCreation {
  final String name;
  final String displayName;
  final List<RemoteCreationStep> steps;
  final RemoteValidator? validator;

  RemoteCreation({
    required this.name,
    required this.displayName,
    required this.steps,
    this.validator,
  });
}