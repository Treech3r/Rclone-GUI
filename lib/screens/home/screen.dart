import 'package:flutter/material.dart';

import '../../utils/check_rclone_installation.dart';
import 'widgets/remote_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Rclone GUI'),
        centerTitle: false,
      ),
      body: FutureBuilder(
        future: getRcloneDriveRemotes(),
        builder: (_, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Center(child: Text('Lendo configuração do rclone...'));
          }

          var remotes = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: remotes.length,
            itemBuilder: (_, index) => RemoteTile(remote: remotes[index]),
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 150,
              mainAxisSpacing: 8,
              mainAxisExtent: 150,
            ),
          );
        },
      ),
    );
  }
}
