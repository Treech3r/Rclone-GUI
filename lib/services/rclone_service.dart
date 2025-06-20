import 'dart:convert';

import '../utils/rclone_server.dart';

class RcloneService {
  static Future<List<Map<String, dynamic>>> getAllRemotes() async {
    var remotesNamesResponse =
        await RcloneServer.request('/config/listremotes');

    if (remotesNamesResponse['remotes'] == null) {
      return [];
    }

    List<String> remotesNames =
        List<String>.from(remotesNamesResponse['remotes']);

    final remotesDetailsResponse = await Future.wait(
      remotesNames.map(
        (name) => RcloneServer.request('/config/get?name=$name'),
      ),
    );

    List<Map<String, dynamic>> remotes = [];

    for (var i = 0; i < remotesNames.length; i++) {
      remotes.add({
        'name': remotesNames[i],
        'type': remotesDetailsResponse[i]['type'],
        'parentRemote': remotesDetailsResponse[i]['remote']
      });
    }

    return remotes;
  }

  static Future<void> createRemote(Map<String, dynamic> parameters) async {
    final remoteName = parameters.remove('name');
    final remoteType = parameters.remove('type');

    await RcloneServer.request(
      '/config/create',
      queryParameters: {
        'name': remoteName,
        'type': remoteType,
        'parameters': jsonEncode(parameters),
        'opt': jsonEncode({'nonInteractive': true})
      },
    );
  }

  static Future<String?> executeCliCommand(
    String command,
    List<String>? arguments,
    Map<String, String>? flags,
  ) async {
    final response = await RcloneServer.request(
      '/core/command',
      queryParameters: {
        'command': command,
        'arg': jsonEncode(arguments),
        'opt': jsonEncode(flags),
      },
    );

    if (response['error']) {
      return '';
    }

    return response['result']
        .replaceAll(r'\n', ' ') // Remove escaped newline characters
        .replaceAll('\n', ' ') // Replace actual newlines with spaces
        .replaceAll(RegExp(r'\s+'), ' ') // Collapse multiple spaces into one
        .trim(); // Remove leading/trailing spaces
  }
}
