import 'package:flutter/material.dart';
import 'package:rimlink/l10n/app_localizations.dart';
import 'package:rimlink/data/locale_service.dart';
import 'package:rimlink/models/data_models.dart';
import 'package:rimlink/data/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class AccountPreferencesPage extends StatelessWidget {
  const AccountPreferencesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.accountPreferences, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: ListView(
        children: [
          _buildCategoryHeader(AppLocalizations.of(context)!.profileInformation),
          _buildItem(AppLocalizations.of(context)!.nameLocationIndustry, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const NameLocationIndustryPage()));
          }),
          _buildCategoryHeader(AppLocalizations.of(context)!.language),
          _buildItem(
            _currentLocaleName(context),
            subtitle: _currentLocaleName(context),
            onTap: () => _showLanguagePicker(context),
          ),
        ],
      ),
    );
  }
}

String _currentLocaleName(BuildContext context) {
  switch (LocaleService.instance.locale.languageCode) {
    case 'ar':
      return AppLocalizations.of(context)!.arabic;
    case 'fr':
      return AppLocalizations.of(context)!.french;
    default:
      return AppLocalizations.of(context)!.english;
  }
}

void _showLanguagePicker(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(AppLocalizations.of(context)!.language),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(AppLocalizations.of(context)!.english),
            leading: Radio<String>(
              value: 'en',
              groupValue: LocaleService.instance.locale.languageCode,
              onChanged: (val) {
                LocaleService.instance.setLocale('en');
                Navigator.pop(context);
              },
            ),
            onTap: () {
              LocaleService.instance.setLocale('en');
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.arabic),
            leading: Radio<String>(
              value: 'ar',
              groupValue: LocaleService.instance.locale.languageCode,
              onChanged: (val) {
                LocaleService.instance.setLocale('ar');
                Navigator.pop(context);
              },
            ),
            onTap: () {
              LocaleService.instance.setLocale('ar');
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.french),
            leading: Radio<String>(
              value: 'fr',
              groupValue: LocaleService.instance.locale.languageCode,
              onChanged: (val) {
                LocaleService.instance.setLocale('fr');
                Navigator.pop(context);
              },
            ),
            onTap: () {
              LocaleService.instance.setLocale('fr');
              Navigator.pop(context);
            },
          ),
        ],
      ),
    ),
  );
}

class NameLocationIndustryPage extends StatefulWidget {
  const NameLocationIndustryPage({super.key});

  @override
  State<NameLocationIndustryPage> createState() => _NameLocationIndustryPageState();
}

class _NameLocationIndustryPageState extends State<NameLocationIndustryPage> {
  final SupabaseService _supabaseService = SupabaseService();
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _industryController;
  bool _isLoading = true;
  User? _user;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _locationController = TextEditingController();
    _industryController = TextEditingController();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = await _supabaseService.getCurrentUserProfile();
    if (mounted && user != null) {
      setState(() {
        _user = user;
        _nameController.text = user.name;
        _locationController.text = user.location;
        _industryController.text = user.title;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _industryController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_user == null) return;
    
    setState(() => _isLoading = true);
    
    final updatedUser = User(
      id: _user!.id,
      name: _nameController.text,
      title: _industryController.text,
      location: _locationController.text,
      about: _user!.about,
      experience: _user!.experience,
      education: _user!.education,
      skills: _user!.skills,
      connections: _user!.connections,
      isOpenToWork: _user!.isOpenToWork,
      isHiring: _user!.isHiring,
      isProvidingServices: _user!.isProvidingServices,
      avatarUrl: _user!.avatarUrl,
      bannerUrl: _user!.bannerUrl,
    );

    await _supabaseService.updateProfile(updatedUser);
    
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.preferencesSaved)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.nameLocationIndustry, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _save,
              child: Text(AppLocalizations.of(context)!.save, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            )
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(AppLocalizations.of(context)!.firstNameLastName, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                ),
                const SizedBox(height: 24),
                
                Text(AppLocalizations.of(context)!.location, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: _locationController,
                  decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                ),
                const SizedBox(height: 24),

                Text(AppLocalizations.of(context)!.industryTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: _industryController,
                  decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                ),
              ],
            ),
          ),
    );
  }
}

class SecurityPage extends StatelessWidget {
  const SecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.signInAndSecurity, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: ListView(
        children: [
          _buildCategoryHeader(AppLocalizations.of(context)!.accountAccess),
          _buildItem(AppLocalizations.of(context)!.emailAddresses, subtitle: AppLocalizations.of(context)!.oneEmailAddress, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (c) => const EmailAddressesPage()));
          }),
          _buildItem(AppLocalizations.of(context)!.changePassword, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (c) => const ChangePasswordPage()));
          }),
        ],
      ),
    );
  }
}

class VisibilityPage extends StatelessWidget {
  const VisibilityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Visibility', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: ListView(
        children: [
          _buildCategoryHeader('Visibility of your profile & network'),
          _buildItem('Profile viewing options', subtitle: 'Your name and headline'),
          _buildItem('Edit your public profile'),
          _buildItem('Who can see or download your email address', subtitle: 'Only visible to me'),
          _buildItem('Connections', subtitle: 'On'),
          _buildItem('Who can see your last name'),
          _buildItem('Representing your organization and interests'),
          _buildItem('Profile discovery and visibility off LinkedIn', subtitle: 'Yes'),
          _buildItem('Profile discovery using email address'),
          _buildItem('Profile discovery using phone number'),
          _buildItem('Blocking'),
        ],
      ),
    );
  }
}

class NotificationsSettingsPage extends StatelessWidget {
  const NotificationsSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: ListView(
        children: [
          _buildCategoryHeader('Notifications you receive'),
          _buildItem('Searching for a job'),
          _buildItem('Hiring someone'),
          _buildItem('Connecting with others'),
          _buildItem('Posting and commenting'),
          _buildItem('Messaging'),
          _buildItem('Groups'),
          _buildItem('Pages'),
          _buildItem('Attending events'),
          _buildItem('News and reports'),
          _buildCategoryHeader('Notification delivery'),
          _buildItem('Push notifications'),
          _buildItem('Email notifications'),
        ],
      ),
    );
  }
}

// Helper methods for list rendering

Widget _buildCategoryHeader(String title) {
  return Container(
    padding: const EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 8),
    color: Colors.grey[100],
    child: Text(
      title.toUpperCase(),
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
    ),
  );
}

Widget _buildItem(String title, {String? subtitle, VoidCallback? onTap}) {
  return ListTile(
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
    subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(color: Colors.grey)) : null,
    trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
    shape: const Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
    onTap: onTap ?? () {},
  );
}

class EmailAddressesPage extends StatelessWidget {
  const EmailAddressesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final email = sb.Supabase.instance.client.auth.currentUser?.email ?? 'Not available';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.emailAddresses, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppLocalizations.of(context)!.primaryEmailAccount,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  const Icon(Icons.email, color: Colors.grey),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(email, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(AppLocalizations.of(context)!.primary, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.addEmailComingSoon)));
              },
              icon: const Icon(Icons.add),
              label: Text(AppLocalizations.of(context)!.addEmailAddress),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
                side: BorderSide(color: Theme.of(context).primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final SupabaseService _supabaseService = SupabaseService();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.passwordsDoNotMatch)));
      return;
    }

    if (_newPasswordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.passwordMinLength)));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _supabaseService.changePassword(_newPasswordController.text);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.passwordChanged)));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${AppLocalizations.of(context)!.error}: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.changePassword, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _save,
              child: Text(AppLocalizations.of(context)!.save, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(AppLocalizations.of(context)!.passwordHint, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 24),
                  _buildPasswordField(AppLocalizations.of(context)!.currentPassword, _currentPasswordController),
                  const SizedBox(height: 16),
                  _buildPasswordField(AppLocalizations.of(context)!.newPassword, _newPasswordController),
                  const SizedBox(height: 16),
                  _buildPasswordField(AppLocalizations.of(context)!.confirmNewPassword, _confirmPasswordController),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.verificationSent)));
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      alignment: Alignment.centerLeft,
                      foregroundColor: Theme.of(context).primaryColor,
                    ),
                    child: Text(AppLocalizations.of(context)!.forgotPassword, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
      ],
    );
  }
}
