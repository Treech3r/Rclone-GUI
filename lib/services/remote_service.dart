import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/remote.dart';
import '../screens/remote_selection/screen.dart';
import 'rclone_service.dart';

class RemoteService extends StateNotifier<List<Remote>> {
  RemoteService._() : super([]);

  static dynamic _instance;

  static StateNotifierProvider<RemoteService, List<Remote>> get instance {
    _instance ??= StateNotifierProvider<RemoteService, List<Remote>>((ref) {
      return RemoteService._();
    });

    return _instance;
  }

  Future<List<Remote>> getAllRemotes({bool force = false}) async {
    if (force || state.isEmpty) {
      await _getAllRemotes();
    }

    return state;
  }

  Future<void> _getAllRemotes() async {
    final List<Map<String, dynamic>> remotesMap =
        await RcloneService.getAllRemotes();

    final Map<String, Remote> remotes = {};
    // Map to store deferred parent relationships (childName -> parentName)
    final deferredParents = <String, String>{};

    for (var i = 0; i < remotesMap.length; i++) {
      final remote = Remote(
        name: remotesMap[i]['name']!,
        type: remotesMap[i]['type']!,
      );

      remotes[remote.name] = remote;

      if (remotesMap[i]['parentRemote'] != null) {
        final String parentName = remotesMap[i]['parentRemote']!.split(':')[0];

        // Link parent immediately if parent is already processed
        if (remotes.containsKey(parentName)) {
          remote.parentRemote = remotes[parentName];
        } else {
          // Store in deferredParents if parent is not yet processed
          deferredParents[remote.name] = parentName;
        }
      }
    }

    // Resolve deferred parent relationships
    for (final entry in deferredParents.entries) {
      final childName = entry.key;
      final parentName = entry.value;

      if (remotes.containsKey(parentName)) {
        remotes[childName]?.parentRemote = remotes[parentName];
      }
    }

    state = remotes.values.toList();
  }

  Future<void> createRemote(Map<String, dynamic> parameters) async {
    await RcloneService.createRemote(parameters);
  }

  Future<Remote?> askUserToSelectRemote(BuildContext context) async {
    return await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => RemoteSelectionScreen()));
  }
}
