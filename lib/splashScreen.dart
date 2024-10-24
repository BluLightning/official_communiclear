import 'package:communi_clear/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'main.dart';

class  SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds:3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    });
  }

  @override
  Widget build (BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('asset/if-you-were-to-look-back-at-skibidi-toilet-18-what-was-your-v0-1fgdflz3gx6c1.jpg', width: 150, height: 150),
            SizedBox(height: 20),
            Text(
              'communi_clear',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}