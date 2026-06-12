import 'package:rimlink/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rimlink/ui/auth/login_signup_page.dart';
import 'package:rimlink/ui/profile/settings_subpages.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(icon: const Icon(Icons.help_outline), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[100],
              child: Text(AppLocalizations.of(context)!.account, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
            ),
            _buildSettingTile(Icons.person, AppLocalizations.of(context)!.accountPreferences, context, const AccountPreferencesPage()),
            _buildSettingTile(Icons.security, AppLocalizations.of(context)!.signInAndSecurity, context, const SecurityPage()),
            
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[100],
              child: Text(AppLocalizations.of(context)!.actions, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.red),
              title: Text(AppLocalizations.of(context)!.signOut, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              onTap: () async {
                await Supabase.instance.client.auth.signOut();
                if (!context.mounted) return;
                // Navigate entirely back to the login page and destroy the route stack
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginSignupPage()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile(IconData icon, String title, BuildContext context, Widget targetPage) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => targetPage),
        );
      },
      shape: const Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
    );
  }
}
