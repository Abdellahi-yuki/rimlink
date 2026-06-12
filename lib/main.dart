import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rimlink/ui/main_navigation.dart';
import 'package:rimlink/ui/auth/login_signup_page.dart';
import 'package:rimlink/data/locale_service.dart';
import 'package:rimlink/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final localeService = LocaleService();
  await localeService.loadLocale();

  await Supabase.initialize(
    url: 'https://psbxqesclpgfhpehfeso.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBzYnhxZXNjbHBnZmhwZWhmZXNvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc0MDc3MzUsImV4cCI6MjA5Mjk4MzczNX0.wZLUj3FRFovaMnNiyta1FAHLZ4nOZ8x6ngs32OcCAz4',
  );

  runApp(RimlinkApp(localeService: localeService));
}

class RimlinkApp extends StatefulWidget {
  final LocaleService localeService;

  const RimlinkApp({super.key, required this.localeService});

  @override
  State<RimlinkApp> createState() => _RimlinkAppState();
}

class _RimlinkAppState extends State<RimlinkApp> {
  late LocaleService _localeService;

  @override
  void initState() {
    super.initState();
    _localeService = widget.localeService;
    _localeService.addListener(_onLocaleChange);
  }

  @override
  void dispose() {
    _localeService.removeListener(_onLocaleChange);
    super.dispose();
  }

  void _onLocaleChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RimLink',
      locale: _localeService.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0A66C2),
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
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.session != null) {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const MainNavigation()),
            (route) => false,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      return const MainNavigation();
    }
    return const LoginSignupPage();
  }
}
