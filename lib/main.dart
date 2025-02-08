import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:official_communiclear/screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black, // Set background to black
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.white), // Default text style for large text
          bodyMedium: TextStyle(color: Colors.white), // Default text style for medium text
          bodySmall: TextStyle(color: Colors.white), // Default text style for small text
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
          iconTheme: IconThemeData(color: Colors.white), // Set AppBar icon color
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20), // Set AppBar title text color
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: SplashScreen(),
    );
  }
}
