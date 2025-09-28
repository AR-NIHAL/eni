import 'package:flutter/material.dart';
import 'package:flutter_ui/app_style.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
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
                  const SizedBox(height: 10),
                  Text(
                    "Lorem lorem lorem",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 25.0,
                      fontWeight: FontWeight.w100,
                      color: blackColor,
                    ),
                  ),
                  Text(
                    "Lorem epsum lorem",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 25.0,
                      fontWeight:FontWeight.w100
                      ),
                    const SizedBox(height: 10),
                      // Subtitle
                      Text(
                        "Lorem lorem lorem",
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontSize: 25.0,
                              fontWeight: FontWeight.w100,
                              color: blackColor,
                            ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
