import 'package:flutter/material.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Column(
        children: [
          Text("Hello Welcome Back"),
          Text("Login to continue"),
          TextField(decoration: InputDecoration(hintText: "Username")),
          TextField(decoration: InputDecoration(hintText: "Password")),
          TextButton(
            onPressed: () {
              print("Clicked");
            },
            child: Text("Forgot Password"),
          ),
          ElevatedButton(onPressed: () {}, child: Text("Log in")),
        ],
      ),
    );
  }
}
