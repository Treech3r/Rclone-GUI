import 'package:flutter/material.dart';

class RemoteTile extends StatelessWidget {
  final Map<String, String> remote;

  const RemoteTile({required this.remote, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.folder),
            SizedBox(height: 12),
            Text(
              remote['name']!,
              softWrap: false,
              overflow: TextOverflow.fade,
            ),
            Opacity(
              opacity: 0.6,
              child: Text(remote['type']!),
            ),
          ],
        ),
      ),
    );
  }
}
