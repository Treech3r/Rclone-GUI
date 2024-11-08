class Remote {
  final String name;
  final String type;

  Remote({required this.name, required this.type});

  factory Remote.fromJson(Map<String, dynamic> json) {
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
}
