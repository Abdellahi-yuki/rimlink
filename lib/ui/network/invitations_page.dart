import 'package:flutter/material.dart';
import 'package:rimlink/data/mock_data.dart';
import 'package:rimlink/ui/profile/profile_page.dart';

class InvitationsPage extends StatefulWidget {
  const InvitationsPage({super.key});

  @override
  State<InvitationsPage> createState() => _InvitationsPageState();
}

class _InvitationsPageState extends State<InvitationsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Manage invitations'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: MockData.invitations.isEmpty
          ? const Center(child: Text('No pending invitations', style: TextStyle(color: Colors.grey, fontSize: 16)))
          : ListView.separated(
              itemCount: MockData.invitations.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final inv = MockData.invitations[index];
                return ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfilePage(user: inv)),
                    );
                  },
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.primaries[inv.name.length % Colors.primaries.length],
                    child: Text(inv.name.substring(0, 1), style: const TextStyle(color: Colors.white, fontSize: 24)),
                  ),
                  title: Text(inv.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(inv.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.cancel_outlined, color: Colors.grey, size: 32),
                        onPressed: () {
                          setState(() {
                            MockData.invitations.remove(inv);
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.check_circle, color: Color(0xFF0A66C2), size: 32),
                        onPressed: () {
                          setState(() {
                            MockData.invitations.remove(inv);
                            // Real app would add them to connections
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
