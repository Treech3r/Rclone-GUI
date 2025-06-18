import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/remote_creation/remote_creation.dart';
import '../models/remote_creation/remote_creation_input.dart';
import '../models/remote_creation/remote_creation_step.dart';

abstract class Config {
  static final remotes = Provider<List<RemoteCreation>>(
    (ref) => [
      RemoteCreation(
        name: 'drive',
        displayName: 'Google Drive',
        steps: [
          RemoteCreationStep(
            type: RemoteCreationStepType.form,
            title: 'Enter Google Drive Credentials',
            description: 'Provide your Google API credentials.',
            parameters: [
              RemoteCreationInput(
                key: 'client_id',
                label: 'Client ID',
                type: RemoteCreationInputType.text,
                required: true,
                hint: 'Enter your Google Client ID',
              ),
              RemoteCreationInput(
                key: 'client_secret',
                label: 'Client Secret',
                type: RemoteCreationInputType.password,
                required: true,
              ),
              RemoteCreationInput(
                key: 'scope',
                label: 'Scope',
                type: RemoteCreationInputType.dropdown,
                options: ['drive', 'drive.readonly', 'drive.file'],
                defaultValue: 'drive',
              ),
            ],
            nextButtonText: 'Authenticate',
          ),
          RemoteCreationStep(
            type: RemoteCreationStepType.asyncTask,
            title: 'Fetching Team Drives',
            asyncTask: (config, ref) async {
              // Placeholder: Replace with actual Google Drive API call
              await Future.delayed(Duration(seconds: 2));
              return {
                'team_drives': [
                  {'id': 'team1', 'name': 'Team Drive 1'},
                  {'id': 'team2', 'name': 'Team Drive 2'},
                ],
              };
            },
          ),
          RemoteCreationStep(
            type: RemoteCreationStepType.form,
            title: 'Test',
            description: 'Test',
            parameters: [
              RemoteCreationInput(
                key: 'client_id',
                label: 'Client ID',
                type: RemoteCreationInputType.text,
                required: true,
                hint: 'Enter your Google Client ID',
              ),
            ],
            nextButtonText: 'Authenticate',
          ),
        ],
        validator: (config) {
          if (config['client_id']!.isEmpty ||
              config['client_secret']!.isEmpty) {
            return 'Client ID and Secret are required';
          }
          return null;
        },
      ),
      RemoteCreation(
        name: 's3',
        displayName: 'Amazon S3',
        steps: [
          RemoteCreationStep(
            type: RemoteCreationStepType.form,
            title: 'Enter S3 Credentials',
            parameters: [
              RemoteCreationInput(
                key: 'access_key_id',
                label: 'Access Key ID',
                type: RemoteCreationInputType.text,
                required: true,
              ),
              RemoteCreationInput(
                key: 'secret_access_key',
                label: 'Secret Access Key',
                type: RemoteCreationInputType.password,
                required: true,
              ),
              RemoteCreationInput(
                key: 'region',
                label: 'Region',
                type: RemoteCreationInputType.text,
                defaultValue: 'us-east-1',
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
