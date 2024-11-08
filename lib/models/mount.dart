import 'remote.dart';

class Mount {
  final int id;
  String name;
  Remote remote;
  String remotePath;
  String mountPoint;
  bool allowWrite;

  Mount({
    required this.id,
    required this.name,
    required this.remote,
    required this.remotePath,
    required this.mountPoint,
    required this.allowWrite,
  });

  factory Mount.fromJson(Map<String, dynamic> json) {
    return Mount(
      id: json['id'],
      name: json['name'],
      remote: json['remote'],
      remotePath: json['remotePath'],
      mountPoint: json['mountPoint'],
      allowWrite: json['allowWrite'] == 0 ? false : true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'remote': remote.name,
      'remotePath': remotePath,
      'mountPoint': mountPoint,
      'allowWrite': allowWrite ? 1 : 0,
    };
  }
}
