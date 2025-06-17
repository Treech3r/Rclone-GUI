class Remote {
  final String name;
  final String type;
  // For crypt remotes and the like;
  late Remote? parentRemote;
  bool mounted;

  Remote({required this.name, required this.type, this.parentRemote, this.mounted = false});

  factory Remote.fromJson(dynamic json) {
    return Remote(
      name: json['name']!,
      type: json['type']!,
      parentRemote: json['parentRemote']!,
    );
  }

  String get getCommercialName {
    return Remote._getCommercialName(this);
  }

  static String _getCommercialName(Remote remote) {
    Map<String, String> commercialNames = {
      'drive': 'Google Drive',
      'dropbox': 'Dropbox',
      'mega': 'Mega',
      'fichier': '1Fichier',
      'netstorage': 'NetStorage',
      's3': 'Amazon S3',
      'b2': 'Backblaze B2',
      'box': 'Box',
      'sharefile': 'Citrix Sharefile',
      'koofr': 'Koofr',
      'filefabric': 'Enterprise File Fabric',
      'filescom': 'Files.com',
      'ftp': 'ftp',
      'gofile': 'Gofile',
      'google cloud storage': 'Google Cloud Storage',
      'google photos': 'Google Photos',
      'hdfs': 'Hadoop distributed file system',
      'hidrive': 'HiDrive',
      'http': 'HTTP',
      'internetarchive': 'Internet Archive',
      'jottacloud': 'Jottacloud',
      'linkbox': 'Linkbox',
      'mailru': 'Mail.ru Cloud',
      'azureblob': 'Microsoft Azure Blob Storage',
      'azurefiles': 'Microsoft Azure Files Storage',
      'onedrive': 'Microsoft OneDrive',
      'swift': 'OpenStack Swift',
      'opendrive': 'OpenDrive',
      'oracleobjectstorage': 'Oracle Cloud Infrastructure Object Storage',
      'pcloud': 'Pcloud',
      'pikpak': 'PikPak',
      'pixeldrain': 'Pixeldrain Filesystem',
      'premiumizeme': 'premiumize.me',
      'putio': 'Put.io',
      'protondrive': 'Proton Drive',
      'qingstor': 'QingStor Object Storage',
      'quatrix': 'Quatrix by Maytech',
      'seafile': 'Seafile',
      'sftp': 'SSH/SFTP',
      'sia': 'Sia Decentralized Cloud',
      'smb': 'SMB',
      'storj': 'Storj Decentralized Cloud Storage',
      'sugarsync': 'Sugarsync',
      'ulozto': 'Uloz.to',
      'uptobox': 'Uptobox',
      'webdav': 'WebDAV',
      'yandex': 'Yandex Disk',
      'zoho': 'Zoho',
      'local': 'Arquivos locais',
      'memory': 'Arquivos na memória RAM'
    };

    if (remote.parentRemote != null) {
      return _getCommercialName(remote.parentRemote!);
    }

    return commercialNames[remote.type] ?? 'Desconhecido';
  }

  String get getCommercialLogo {
    return _getCommercialLogo(this);
  }

  static String _getCommercialLogo(Remote remote) {
    Set<String> availableLogos = {
      'drive',
      'dropbox',
      'mega',
      'webdav',
      'sftp',
      'protondrive',
      'pixeldrain',
      'onedrive',
      'google photos',
      's3',
    };

    if (remote.parentRemote != null) {
      return _getCommercialLogo(remote.parentRemote!);
    }

    return 'assets/images/cloud_storage_logos/${availableLogos.contains(remote.type) ? remote.type : 'generic_cloud_logo'}.svg';
  }

  @override
  String toString() {
    return 'Remote($name:, type: $type, parentRemote: $parentRemote, mounted: $mounted)';
  }
}
