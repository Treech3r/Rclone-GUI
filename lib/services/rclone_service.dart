import '../utils/rclone.dart' as rclone_utils;

class RcloneService {
  static Future<List<Map<String, dynamic>>> getAllRemotes() async {
    var remotesNamesResponse =
        await rclone_utils.requestToRcloneApi('/config/listremotes');

    if (remotesNamesResponse['remotes'] == null) {
      return [];
    }

    List<String> remotesNames =
        List<String>.from(remotesNamesResponse['remotes']);

    final remotesDetailsResponse = await Future.wait(
      remotesNames.map(
        (name) => rclone_utils.requestToRcloneApi('/config/get?name=$name'),
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
}
