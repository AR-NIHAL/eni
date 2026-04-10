import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StateProviderTutorial(),
    );
  }
}
class StateProviderTutorial extends ConsumerWidget {
  const StateProviderTutorial({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('build method loaded');
    return Scaffold(
      appBar: AppBar(title: Text('State Provider Tutorial')),
      floatingActionButton: IconButton(
        onPressed: () {
          ref.read(counterProvider.notifier).state++;
        },
        icon: Icon(Icons.add),
      ), // IconButton
      body: Center(
        child: Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            final counter = ref.watch(counterProvider);
            print('Consumer method loaded');
            return Text(counter.toString());
          },
        ), // Consumer
      ), // Center
    ); // Scaffold
  }
} 