import 'package:flutter/material.dart';

import '../../services/sqflite.dart';

class MountsScreen extends StatefulWidget {
  const MountsScreen({super.key});

  @override
  State<MountsScreen> createState() => _MountsScreenState();
}

class _MountsScreenState extends State<MountsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        child: Icon(Icons.add),
      ),
      body: FutureBuilder(
        future: SqfliteService.getAllMounts(),
        builder: (_, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Center(child: Text('Buscando remotes...'));
          }

          var remotes = snapshot.data!;

          if (remotes.isEmpty) {
            return EmptyWarning();
          }

          // TODO: return actual data
          return Container();
        },
      ),
    );
  }
}

class EmptyWarning extends StatelessWidget {
  const EmptyWarning({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(children: []),
        Text(
          'Um pouco vazio por aqui...',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        SizedBox(height: 20),
        Image.asset(
          'assets/images/treecher_sleeping.png',
          height: MediaQuery.of(context).size.height * 0.4,
        ),
        SizedBox(height: 20),
        Text(
          'Que tal criar seu primeiro mount?',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ],
    );
  }
}
