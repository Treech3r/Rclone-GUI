import 'package:rclone_gui/services/rclone_service.dart';

import '../models/remote.dart';

class RemoteService {
  List<Remote> _remotes = [];

  Future<void> initialize() async {
    List<Map<String, String>> remotesNames = await RcloneService.getAllRemotes();

    if (remotesNames.isEmpty) {
      return;
    }
  }
}