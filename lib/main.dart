import 'package:flutter/material.dart';
import 'package:rimlink/ui/auth/login_signup_page.dart';

void main() {
  runApp(const RimlinkApp());
}

class RimlinkApp extends StatelessWidget {
  const RimlinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RimLink',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0A66C2), // LinkedIn blue
          primary: const Color(0xFF0A66C2),
        ),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const LoginSignupPage(),
    );
  }
}
