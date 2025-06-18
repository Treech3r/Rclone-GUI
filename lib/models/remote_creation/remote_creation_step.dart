import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'remote_creation_input.dart';

enum RemoteCreationStepType {
  form,
  asyncTask,
  selection,
  custom,
}

class RemoteCreationStep {
  final RemoteCreationStepType type;
  final String title;
  final List<RemoteCreationInput>? parameters;
  final Future<Map<String, dynamic>> Function(Map<String, String>, Ref)? asyncTask;
  final Widget Function(Map<String, dynamic>, WidgetRef)? customBuilder;
  final String? nextButtonText;
  final String? description;

  RemoteCreationStep({
    required this.type,
    required this.title,
    this.parameters,
    this.asyncTask,
    this.customBuilder,
    this.nextButtonText,
    this.description,
  });
}