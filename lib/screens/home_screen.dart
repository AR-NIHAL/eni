import 'package:flutter/material.dart';
import 'package:flutter_ui/app_style.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        height: 250,
        child: Stack(
          children: [
            Container(
              height: 200,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              decoration: BoxDecoration(
                color: yellowColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        Icons.arrow_back_ios_rounded,
                        color: whiteColor,
                        size: 30,
                      ),
                      Icon(Icons.search_outlined, color: whiteColor, size: 30),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    "LOREM",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 35.0,
                      fontWeight: FontWeight.w400, // The desired font size
                      color: blackColor,
                    ),
                  ),
                  Text(
                    "LOREM qwer ty uio op kjhg asdf okmnhy",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w400, // The desired font size
                      color: blackColor,
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              left: -10,
              bottom: 20,
              child: Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      color: Colors.pinkAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
