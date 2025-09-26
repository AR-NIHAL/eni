import 'package:flutter/material.dart';
import 'package:flutter_ui/app_style.dart';
import 'package:flutter_ui/screens/home_screen.dart';
import 'package:flutter_ui/screens/notification_screen.dart';
import 'package:flutter_ui/screens/proifle_screen.dart';

class BottomBarScreen extends StatefulWidget {
  const BottomBarScreen({super.key});

  @override
  State<BottomBarScreen> createState() => _BottomBarScreenState();
}

class _BottomBarScreenState extends State<BottomBarScreen> {
  int pageIndex = 0;
  static final List<Widget> page = [
    const HomeScreen(),
    const NotificationScreen(),
    const ProifleScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        height: 50,
        margin: EdgeInsets.only(left: 30, bottom: 30, right: 30),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  pageIndex = 0;
                });
              },
              icon: pageIndex == 0
                  ? Icon(Icons.home_filled, color: blueGreyColor, size: 35)
                  : Icon(Icons.home_filled, color: grey300, size: 35),
            ),

            IconButton(
              onPressed: () {
                setState(() {
                  pageIndex = 1;
                });
              },
              icon: pageIndex == 1
                  ? Icon(
                      Icons.notifications_rounded,
                      color: blueGreyColor,
                      size: 35,
                    )
                  : Icon(Icons.notifications_rounded, color: grey300, size: 35),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  pageIndex = 2;
                });
              },
              icon: pageIndex == 2
                  ? Icon(Icons.settings, color: blueGreyColor, size: 35)
                  : Icon(Icons.settings, color: grey300, size: 35),
            ),
          ],
        ),
      ),
    );
  }
}
