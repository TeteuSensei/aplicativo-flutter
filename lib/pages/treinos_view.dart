import 'package:flutter/material.dart';

class TreinosView extends StatelessWidget {
  const TreinosView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Sem treinos ainda', style: Theme.of(context).textTheme.titleLarge),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Novo treino'),
      ),
    );
  }
}
