class Remote {
  final String name;
  final String type;
  bool mounted;

  Remote({required this.name, required this.type, this.mounted = false});

  factory Remote.fromJson(dynamic json) {
    return Remote(
      name: json['name']!,
      type: json['type']!,
    );
  }

  String get getCommercialName {
    switch (type) {
      case 'drive':
        return 'Google Drive';
      default:
        return 'Unknown';
    }
  }

  String get getCommercialLogo {
    switch (type) {
      case 'drive':
        return 'assets/images/drive_logo.svg';
      default:
        return '';
    }
  }

  @override
  String toString() {
    return 'Remote($name:, type: $type, mounted: $mounted)';
  }
}
