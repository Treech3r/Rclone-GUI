import 'package:flutter/material.dart';
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
                'Todos os valores são opcionais, exceto o nome.',
            parameters: [
              RemoteCreationTextInput(
                key: 'name',
                label: 'Dê um nome para o seu Google Drive',
                prefixIcon: Icons.drive_file_rename_outline,
                hint:
                    'É possível conectar várias contas do Google Drive simultaneamente, então você precisa nomear cada conta para lhe ajudar a identificar no futuro.',
                type: RemoteCreationInputType.text,
                required: true,
              ),
              RemoteCreationTextInput(
                key: 'client_id',
                label: 'Client ID',
                prefixIcon: Icons.account_circle_outlined,
                hint:
                    'Você pode criar um Client ID no Google Cloud Console. É recomendado criar um Client ID para evitar limites de requisições.',
                type: RemoteCreationInputType.text,
              ),
              RemoteCreationTextInput(
                key: 'client_secret',
                label: 'Client Secret',
                prefixIcon: Icons.key_outlined,
                hint:
                    'Você pode criar um Client Secret no Google Cloud Console. É recomendado criar um Client Secret para evitar limites de requisições.',
                type: RemoteCreationInputType.password,
              ),
              RemoteCreationTextInput(
                key: 'root_folder_id',
                label: 'ID de pasta raiz',
                prefixIcon: Icons.folder_outlined,
                hint:
                    'Se você informar um ID de pasta raiz, o rclone só irá acessar essa pasta e suas subpastas. Se não definir, o rclone irá acessar todo o seu Google Drive.',
                type: RemoteCreationInputType.text,
              ),
              RemoteCreationTextInput(
                key: 'team_drive',
                label: 'ID de Drive de Equipe',
                prefixIcon: Icons.folder_outlined,
                hint:
                    'Se você não informar um ID de Drive de Equipe, o rclone irá usar o seu Google Drive pessoal. Você pode informar um ID de Drive de Equipe para montar um Drive de Equipe específico.',
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
                      'Acesso total aos arquivos.',
                  'drive.readonly':
                      'Acesso somente de leitura (metadados e conteúdos dos arquivos).',
                  'drive.file':
                      'Acesso somente a arquivos criados pelo próprio rclone.',
                  'drive.appfolder':
                      'Acesso de escrita e leitura somente à pasta especial de dados de aplicativos. Estes arquivos não são visíveis no site do Google Drive.',
                  'drive.metadata.readonly':
                      'Acesso somente de leitura somente aos metadados dos arquivos. Não permite ver o conteúdo dos arquivos ou fazer download.'
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
    ],
  );
}
