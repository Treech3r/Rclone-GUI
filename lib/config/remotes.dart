import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/remote_creation/remote_creation.dart';
import '../models/remote_creation/remote_creation_input.dart';
import '../models/remote_creation/remote_creation_step.dart';
import '../services/rclone_service.dart';

abstract class Config {
  static final remotes = Provider<List<RemoteCreation>>(
    (ref) => [
      RemoteCreation(
        type: 'drive',
        displayName: 'Google Drive',
        steps: [
          RemoteCreationStep(
            type: RemoteCreationStepType.form,
            title: 'Informações básicas',
            description:
                'Informe suas credenciais do Google Drive API, ID da pasta raiz e ID do Drive de Equipe.\nTodos os valores são opcionais.',
            parameters: [
              RemoteCreationTextInput(
                key: 'name',
                label: 'Nome do Remote',
                type: RemoteCreationInputType.text,
                required: true,
              ),
              RemoteCreationTextInput(
                key: 'client_id',
                label: 'Client ID',
                type: RemoteCreationInputType.text,
              ),
              RemoteCreationTextInput(
                key: 'client_secret',
                label: 'Client Secret',
                type: RemoteCreationInputType.password,
              ),
              RemoteCreationTextInput(
                key: 'root_folder_id',
                label: 'ID da pasta raiz',
                hint:
                    'Caso deixe em branco, a pasta raiz será a pasta raiz do seu drive (ou Drive de Equipe, caso você insira um ID abaixo).',
                type: RemoteCreationInputType.text,
              ),
              RemoteCreationTextInput(
                key: 'team_drive',
                label: 'ID do Drive de Equipe',
                hint:
                    'Se você informou um ID de pasta raiz acima, certifique-se de que a pasta reside dentro deste Drive de Equipe, e não no seu drive pessoal.',
                type: RemoteCreationInputType.text,
              ),
            ],
          ),
          RemoteCreationStep(
            type: RemoteCreationStepType.form,
            title: 'Escopo e autenticação',
            description:
                '"Escopo" pode ser entendido como o "nível de permissão" que o rclone terá na sua conta do Google Drive. Selecione uma opção abaixo conforme a sua necessidade.',
            parameters: [
              RemoteCreationTextInput(
                key: 'scope',
                label: 'Escopo',
                type: RemoteCreationInputType.dropdown,
                options: {
                  'drive':
                      'Acesso total aos arquivos, exceto à pasta especial de dados de aplicativos.',
                  'drive.readonly':
                      'Acesso somente de leitura (metadados e conteúdos dos arquivos).',
                  'drive.file':
                      'Acesso somente a arquivos criados pelo próprio rclone.',
                  'drive.appfolder':
                      'Acesso de escrita e leitura à pasta especial de dados de aplicativos. Estes arquivos não são visíveis no site do Google Drive.',
                  'drive.metadata.readonly':
                      'Acesso somente de leitura aos metadados dos arquivos. Não permite ver o conteúdo dos arquivos ou fazer download.'
                },
                defaultValue: 'drive',
              ),
            ],
            nextButtonText: 'Fazer login com Google Drive',
          ),
          RemoteCreationStep(
            type: RemoteCreationStepType.asyncTask,
            title: 'Autenticando com Google Drive...',
            asyncTask: (config, ref) async {
              final token = await RcloneService.executeCliCommand('authorize',
                      ['drive'], {'drive-scope': config['scope'] ?? ''}) ??
                  '';
              final regex =
                  RegExp(r'--->\s*(\{.*?\})\s*<---End paste', dotAll: true);
              final match = regex.firstMatch(token);

              return {'token': match?.group(1)};
            },
          ),
        ],
        validator: (config) {
          return null;
        },
      ),
      RemoteCreation(
        type: 's3',
        displayName: 'Amazon S3',
        steps: [
          RemoteCreationStep(
            type: RemoteCreationStepType.form,
            title: 'Enter S3 Credentials',
            parameters: [
              RemoteCreationTextInput(
                key: 'access_key_id',
                label: 'Access Key ID',
                type: RemoteCreationInputType.text,
                required: true,
              ),
              RemoteCreationTextInput(
                key: 'secret_access_key',
                label: 'Secret Access Key',
                type: RemoteCreationInputType.password,
                required: true,
              ),
              RemoteCreationTextInput(
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
