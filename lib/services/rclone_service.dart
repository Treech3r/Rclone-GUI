import '../utils/rclone.dart' as rclone_utils;

class RcloneService {
  static Future<List<Map<String, String>>> getAllRemotes() {
    return rclone_utils.getAllRemotes();
  }
}