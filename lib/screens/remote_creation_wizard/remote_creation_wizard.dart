import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/remote_creation/remote_creation.dart';
import '../../models/remote_creation/remote_creation_state_manager.dart';
import '../../models/remote_creation/remote_creation_step.dart';
import 'widgets/remote_creation_step_form.dart';

class RemoteCreationWizard extends ConsumerStatefulWidget {
  final RemoteCreation remoteCreation;
  final Function(Map<String, dynamic>) onComplete;

  const RemoteCreationWizard({
    super.key,
    required this.remoteCreation,
    required this.onComplete,
  });

  @override
  RemoteConfigWizardState createState() => RemoteConfigWizardState();
}

class RemoteConfigWizardState extends ConsumerState<RemoteCreationWizard> {
  @override
  void initState() {
    super.initState();
    // Trigger async task when the widget is first initialized for an asyncTask step
    final notifier = ref.read(remoteCreationStateManagerProvider(widget.remoteCreation).notifier);
    final step = notifier.currentStep;
    if (step.type == RemoteCreationStepType.asyncTask) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifier.nextStep();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(remoteCreationStateManagerProvider(widget.remoteCreation));
    final notifier = ref.read(remoteCreationStateManagerProvider(widget.remoteCreation).notifier);
    final step = notifier.currentStep;

    return Scaffold(
      appBar: AppBar(
        title: Text(step.title),
        leading: state.currentStepIndex > 0
            ? IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => notifier.previousStep(),
        )
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (step.description != null) ...[
              Text(step.description!, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 16),
            ],
            Expanded(
              child: _buildStepContent(context, ref, state, notifier),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (state.currentStepIndex > 0)
                  TextButton(
                    onPressed: () => notifier.previousStep(),
                    child: const Text('Back'),
                  ),
                ElevatedButton(
                  onPressed: state.isLoading
                      ? null
                      : () async {
                    if (step.type == RemoteCreationStepType.form || step.type == RemoteCreationStepType.selection) {
                      return;
                    }
                    await notifier.nextStep();
                    if (notifier.isLastStep) {
                      final error = await notifier.submit();
                      if (error != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(error)),
                        );
                      } else {
                        widget.onComplete(state.config);
                        Navigator.pop(context);
                      }
                    }
                  },
                  child: Text(
                    state.isLoading
                        ? 'Loading...'
                        : notifier.isLastStep
                        ? 'Create Remote'
                        : step.nextButtonText ?? 'Next',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent(
      BuildContext context,
      WidgetRef ref,
      RemoteCreationState state,
      RemoteCreationStateManager notifier,
      ) {
    final step = notifier.currentStep;

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${state.error}'),
            TextButton(
              onPressed: () => notifier.nextStep(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    switch (step.type) {
      case RemoteCreationStepType.form:
        return RemoteCreationStepForm(
          step: step,
          onSubmit: (formData){
            notifier.nextStep(formData: formData);
          },
        );
      case RemoteCreationStepType.asyncTask:
        return const Center(child: CircularProgressIndicator());
      case RemoteCreationStepType.selection:
      case RemoteCreationStepType.custom:
        return step.customBuilder!(state.config, ref);
      }
  }
}