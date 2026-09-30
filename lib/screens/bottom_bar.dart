import 'package:flutter/material.dart';
import '../app_style.dart';
import 'home_screen.dart';
import 'notification_screen.dart';
import 'profile_screen.dart';
import 'state_provider_screen.dart';

class BottomBarScreen extends StatefulWidget {
  const BottomBarScreen({super.key});

  @override
  State<BottomBarScreen> createState() => _BottomBarScreenState();
}

class _BottomBarScreenState extends State<BottomBarScreen> {
  int pageIndex = 0;

  static final List<Widget> pages = [
    const HomeScreen(),
    const StateProviderTutorial(),
    const NotificationScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: IndexedStack(
        index: pageIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        height: 60,
        margin: const EdgeInsets.only(left: 24, bottom: 24, right: 24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : whiteColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              tooltip: 'Home',
              onPressed: () {
                setState(() {
                  pageIndex = 0;
                });
              },
              icon: Icon(
                Icons.home_filled,
                color: pageIndex == 0 ? blueGreyColor : (isDark ? Colors.white30 : grey300),
                size: 32,
              ),
            ),
            IconButton(
              tooltip: 'Riverpod Tutorial',
              onPressed: () {
                setState(() {
                  pageIndex = 1;
                });
              },
              icon: Icon(
                Icons.swap_vert_circle_rounded,
                color: pageIndex == 1 ? blueGreyColor : (isDark ? Colors.white30 : grey300),
                size: 32,
              ),
            ),
            IconButton(
              tooltip: 'Notifications',
              onPressed: () {
                setState(() {
                  pageIndex = 2;
                });
              },
              icon: Icon(
                Icons.notifications_rounded,
                color: pageIndex == 2 ? blueGreyColor : (isDark ? Colors.white30 : grey300),
                size: 32,
              ),
            ),
            IconButton(
              tooltip: 'Profile & Settings',
              onPressed: () {
                setState(() {
                  pageIndex = 3;
                });
              },
              icon: Icon(
                Icons.settings_rounded,
                color: pageIndex == 3 ? blueGreyColor : (isDark ? Colors.white30 : grey300),
                size: 32,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
