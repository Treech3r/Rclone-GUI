import 'package:flutter/material.dart';

import 'remote.dart';

class Mount {
  final int id;
  String? name;
  Remote? remote;
  String remotePath;
  String mountPath;
  bool allowWrite;
  ValueNotifier<bool> isMounted = ValueNotifier(false);

  Mount({
    required this.id,
    required this.name,
    required this.remote,
    required this.remotePath,
    required this.mountPath,
    required this.allowWrite,
  }) {
    isMounted.value = remote?.mounted ?? false;
  }

  factory Mount.fromJson(Map<String, dynamic> json) {
    return Mount(
      id: json['id'],
      name: json['name'],
      remote: json['remote'],
      remotePath: json['remotePath'],
      mountPath: json['mountPath'],
      allowWrite: json['allowWrite'] == 0 ? false : true,
    );
  }

  Mount copyWith({
    int? id,
    String? name,
    Remote? remote,
    String? remotePath,
    String? mountPath,
    bool? allowWrite,
  }) {
    return Mount(
      id: id ?? this.id,
      name: name ?? this.name,
      remote: remote ?? this.remote,
      remotePath: remotePath ?? this.remotePath,
      mountPath: mountPath ?? this.mountPath,
      allowWrite: allowWrite ?? this.allowWrite,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'remote': remote?.name ?? '',
      'remotePath': remotePath,
      'mountPath': mountPath,
      'allowWrite': allowWrite ? 1 : 0,
    };
  }

  void toggleMountStatus() {
    isMounted.value = !isMounted.value;
  }
}
