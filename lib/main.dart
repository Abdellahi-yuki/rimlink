import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rimlink/ui/auth/login_signup_page.dart';
import 'package:rimlink/ui/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://psbxqesclpgfhpehfeso.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBzYnhxZXNjbHBnZmhwZWhmZXNvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc0MDc3MzUsImV4cCI6MjA5Mjk4MzczNX0.wZLUj3FRFovaMnNiyta1FAHLZ4nOZ8x6ngs32OcCAz4',
  );

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
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Listen for auth state changes (e.g. user confirms email in browser)
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.session != null) {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => MainNavigation()),
            (route) => false,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Initial loading or show login page
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      return MainNavigation();
    }
    return const LoginSignupPage();
  }
}
