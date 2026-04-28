import 'package:flutter/material.dart';
import 'package:rimlink/data/mock_data.dart';

class AccountPreferencesPage extends StatelessWidget {
  const AccountPreferencesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Account preferences', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: ListView(
        children: [
          _buildCategoryHeader('Profile information'),
          _buildItem('Name, location, and industry', onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const NameLocationIndustryPage()));
          }),
          _buildCategoryHeader('Display'),
          _buildItem('Dark mode', subtitle: 'Light', onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const DarkModePage()));
          }),
        ],
      ),
    );
  }
}

class NameLocationIndustryPage extends StatefulWidget {
  const NameLocationIndustryPage({super.key});

  @override
  State<NameLocationIndustryPage> createState() => _NameLocationIndustryPageState();
}

class _NameLocationIndustryPageState extends State<NameLocationIndustryPage> {
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _industryController;

  @override
  void initState() {
    super.initState();
    final user = MockData.currentUser;
    _nameController = TextEditingController(text: user.name);
    _locationController = TextEditingController(text: user.location);
    _industryController = TextEditingController(text: user.title);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _industryController.dispose();
    super.dispose();
  }

  void _save() {
    setState(() {
      MockData.currentUser.name = _nameController.text;
      // Location is final on the model right now, so we skip altering it or alter the model if needed, 
      // but for mockup updating title and name works!
      MockData.currentUser.title = _industryController.text;
    });
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preferences saved successfully')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Name, location, and industry', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('First and last name', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
            ),
            const SizedBox(height: 24),
            
            const Text('Location', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _locationController,
              // Ideally update models if you want it mutable, keeping read-only edit visual for mock
              decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
            ),
            const SizedBox(height: 24),

            const Text('Industry (Title)', style: TextStyle(fontWeight: FontWeight.bold)),
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

class DarkModePage extends StatefulWidget {
  const DarkModePage({super.key});

  @override
  State<DarkModePage> createState() => _DarkModePageState();
}

class _DarkModePageState extends State<DarkModePage> {
  String _selectedMode = 'Light mode';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Dark mode', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Select how your LinkedIn experience looks on this device.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
          RadioListTile<String>(
            title: const Text('Device settings'),
            value: 'Device settings',
            groupValue: _selectedMode,
            onChanged: (val) => setState(() => _selectedMode = val!),
          ),
          RadioListTile<String>(
            title: const Text('Dark mode'),
            value: 'Dark mode',
            groupValue: _selectedMode,
            onChanged: (val) => setState(() => _selectedMode = val!),
          ),
          RadioListTile<String>(
            title: const Text('Light mode'),
            value: 'Light mode',
            groupValue: _selectedMode,
            onChanged: (val) => setState(() => _selectedMode = val!),
          ),
          const SizedBox(height: 32),
          Center(
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Theme set to $_selectedMode')));
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, padding: const EdgeInsets.symmetric(horizontal: 32)),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          )
        ],
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
        title: const Text('Sign in & security', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: ListView(
        children: [
          _buildCategoryHeader('Account access'),
          _buildItem('Email addresses', subtitle: '1 email address', onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (c) => const EmailAddressesPage()));
          }),
          _buildItem('Change password', onTap: () {
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Email addresses', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Primary email account',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(
                children: [
                  Icon(Icons.email, color: Colors.grey),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('yuki.dev@example.com', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Primary', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add email flow coming soon!')));
              },
              icon: const Icon(Icons.add),
              label: const Text('Add email address'),
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

class ChangePasswordPage extends StatelessWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Change password', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password successfully changed!')));
            },
            child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Create a new, strong password that you don\'t use for other websites.', style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 24),
            _buildPasswordField('Type your current password'),
            const SizedBox(height: 16),
            _buildPasswordField('Type your new password'),
            const SizedBox(height: 16),
            _buildPasswordField('Retype your new password'),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Verification sent to primary email address.')));
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                alignment: Alignment.centerLeft,
                foregroundColor: Theme.of(context).primaryColor,
              ),
              child: const Text('Forgot password?', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const TextField(
          obscureText: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
      ],
    );
  }
}
