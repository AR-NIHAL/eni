import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../app_style.dart';

// StateProvider for the counter tutorial from riverpod_app
final counterProvider = StateProvider<int>((ref) => 0);

class StateProviderTutorial extends ConsumerWidget {
  const StateProviderTutorial({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('build method loaded');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('State Provider Tutorial'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: indigoColor,
        foregroundColor: whiteColor,
        onPressed: () {
          ref.read(counterProvider.notifier).state++;
        },
        child: const Icon(Icons.add),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Riverpod State Management',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : indigoColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'StateProvider counter example',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : whiteColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  border: Border.all(
                    color: blueGreyColor.withValues(alpha: 0.3),
                    width: 3,
                  ),
                ),
                alignment: Alignment.center,
                child: Consumer(
                  builder: (BuildContext context, WidgetRef ref, Widget? child) {
                    final counter = ref.watch(counterProvider);
                    debugPrint('Consumer method loaded');
                    return Text(
                      counter.toString(),
                      style: TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        color: blueGreyColor,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 36),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      if (ref.read(counterProvider.notifier).state > 0) {
                        ref.read(counterProvider.notifier).state--;
                      }
                    },
                    icon: const Icon(Icons.remove),
                    label: const Text('Decrement'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: () {
                      ref.read(counterProvider.notifier).state = 0;
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
