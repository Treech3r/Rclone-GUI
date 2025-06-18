import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'remote_creation.dart';
import 'remote_creation_step.dart';

class RemoteCreationState {
  final int currentStepIndex;
  final Map<String, dynamic> config;
  final bool isLoading;
  final String? error;
  final bool taskInitiated;

  RemoteCreationState({
    required this.currentStepIndex,
    required this.config,
    this.isLoading = false,
    this.error,
    this.taskInitiated = false,
  });

  RemoteCreationState copyWith({
    int? currentStepIndex,
    Map<String, dynamic>? config,
    bool? isLoading,
    String? error,
    bool? taskInitiated,
  }) {
    return RemoteCreationState(
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      config: config ?? this.config,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      taskInitiated: taskInitiated ?? this.taskInitiated,
    );
  }
}

class RemoteCreationStateManager extends StateNotifier<RemoteCreationState> {
  final RemoteCreation remoteCreation;
  final Ref ref;

  RemoteCreationStateManager(this.remoteCreation, this.ref)
      : super(RemoteCreationState(currentStepIndex: 0, config: {}));

  RemoteCreationStep get currentStep => remoteCreation.steps[state.currentStepIndex];
  bool get canGoNext => state.currentStepIndex < remoteCreation.steps.length - 1;
  bool get isLastStep => state.currentStepIndex == remoteCreation.steps.length - 1;

  Future<void> nextStep({Map<String, String>? formData}) async {
    state = state.copyWith(
      config: {...state.config, if (formData != null) ...formData},
      isLoading: false,
      error: null,
      taskInitiated: false,
    );

    if (canGoNext) {
      state = state.copyWith(currentStepIndex: state.currentStepIndex + 1);
    }

    if (currentStep.type == RemoteCreationStepType.asyncTask && currentStep.asyncTask != null && !state.taskInitiated) {
      state = state.copyWith(isLoading: true, taskInitiated: true);
      try {
        final result = await currentStep.asyncTask!(state.config.cast<String, String>(), ref);
        state = state.copyWith(config: {...state.config, ...result}, isLoading: false);
      } catch (e) {
        state = state.copyWith(isLoading: false, error: e.toString());
        return;
      }
    }

    if (canGoNext) {
      state = state.copyWith(currentStepIndex: state.currentStepIndex + 1);
    }
  }

  void previousStep() {
    if (state.currentStepIndex > 0) {
      state = state.copyWith(currentStepIndex: state.currentStepIndex - 1, error: null, taskInitiated: false);
    }
  }

  void updateConfig(Map<String, dynamic> data) {
    state = state.copyWith(config: {...state.config, ...data});
  }

  Future<String?> submit() async {
    if (remoteCreation.validator != null) {
      return remoteCreation.validator!(state.config.cast<String, String>());
    }
    return null;
  }
}

final remoteCreationStateManagerProvider = StateNotifierProvider.family<
    RemoteCreationStateManager, RemoteCreationState, RemoteCreation>(
  (ref, remoteType) => RemoteCreationStateManager(remoteType, ref),
);
