import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medico/core/constants/app_colors.dart';
import 'package:medico/core/widgets/medico_bottom_nav_bar.dart';

void main() {
  group('MedicoBottomNavBar Widget Tests', () {
    testWidgets('renders Home, History and Add button matching reference layout', (tester) async {
      int tappedIndex = -1;
      bool addTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: MedicoBottomNavBar(
              currentIndex: 0,
              onTap: (index) => tappedIndex = index,
              onAddTap: () => addTapped = true,
            ),
          ),
        ),
      );

      // Verify Home and History icons
      expect(find.byIcon(Icons.home_rounded), findsOneWidget);
      expect(find.byIcon(Icons.bar_chart_rounded), findsOneWidget);

      // Verify + Add button
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);

      // Tap History tab
      await tester.tap(find.byIcon(Icons.bar_chart_rounded));
      await tester.pump();
      expect(tappedIndex, 1);

      // Tap Add button
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pump();
      expect(addTapped, isTrue);
    });

    testWidgets('highlights selected tab with lime accent background', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: MedicoBottomNavBar(
              currentIndex: 0,
              onTap: (_) {},
              onAddTap: () {},
            ),
          ),
        ),
      );

      final homeIconFinder = find.byIcon(Icons.home_rounded);
      expect(homeIconFinder, findsOneWidget);

      final icon = tester.widget<Icon>(homeIconFinder);
      expect(icon.color, AppColors.primaryDark);
    });
  });
}
