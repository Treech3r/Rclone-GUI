import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:process_run/process_run.dart';

const kBaseUrl = "http://localhost:8965";

// This shell should be global. Otherwise, it will be destroyed by garbage
// collector, effectively taking down the server.
Shell? _serverShell;

abstract class RcloneServer {
  static Future<bool> start() async {
    if (await _isServerRunning()) {
      return true;
    }

    _startRcloneServer();

    int attempts = 0;
    while (attempts < 40 && !(await _isServerRunning())) {
      await Future.delayed(Duration(milliseconds: 300));
      attempts++;
    }

    if (await _isServerRunning()) {
      return true;
    }

    return false;
  }

  static Future<bool> _isServerRunning() async {
    try {
      var response = await http.post(Uri.parse('$kBaseUrl/options/get'));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static void _startRcloneServer() async {
    if (_serverShell != null) {
      _serverShell!.kill();
    }

    _serverShell = Shell(
      throwOnError: false,
      // Open shell in application directory because rclone binary will be
      // bundled in final build
      workingDirectory: Directory.current.path,
    );

    // Uses the full path to the rclone binary on macOS due to my laziness in
    // finding a way to include the rclone binary in the final release
    String rcloneBin = Platform.isMacOS ? '/usr/local/bin/rclone' : 'rclone';

    _serverShell!.run('$rcloneBin rcd --rc-addr=localhost:8965 --rc-no-auth');
  }

  static Future<Map<String, dynamic>> request(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    var uri =
        Uri.parse('$kBaseUrl$path').replace(queryParameters: queryParameters);

    http.Response? response;

    int maxRetries = 3;
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        response = await http.post(uri);
        if (response.statusCode == 200) {
          break;
        }
      } catch (_) {
        await start();
        retryCount++;
      }
    }

    if (response == null) {
      throw Error();
    }

    if (response.statusCode != 200) {
      throw Error();
    }

    return jsonDecode(response.body);
  }
}
