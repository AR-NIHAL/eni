import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eni/main.dart';

void main() {
  testWidgets('Unified app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    // Verify that the app mounts properly.
    expect(find.byType(MyApp), findsOneWidget);
  });
}
