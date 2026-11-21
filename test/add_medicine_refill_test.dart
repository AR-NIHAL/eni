import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medico/features/medicine/presentation/screens/add_medicine_screen.dart';

void main() {
  testWidgets('AddMedicineScreen renders Inventory & Refill card and toggles controls', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: AddMedicineScreen(),
        ),
      ),
    );

    // Scroll until switch is visible using the main scrollable
    await tester.scrollUntilVisible(
      find.text('Track inventory & refills'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Track inventory & refills'), findsOneWidget);
    expect(find.byType(Switch), findsOneWidget);

    // Initially turned off
    expect(find.text('Current supply'), findsNothing);

    // Toggle ON
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    // Now supply and alert threshold are visible
    expect(find.text('Current supply'), findsOneWidget);
    expect(find.text('Remind me when supply drops to'), findsOneWidget);
    expect(find.text('30 pack'), findsOneWidget);

    // Tap 60 pack preset
    await tester.tap(find.text('60 pack'));
    await tester.pumpAndSettle();
    expect(find.text('60'), findsOneWidget);
  });
}
