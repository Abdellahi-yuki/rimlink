import 'package:flutter/material.dart';
import 'package:rimlink/data/supabase_service.dart';
import 'package:rimlink/models/data_models.dart';
import 'package:rimlink/ui/profile/profile_page.dart';

class InvitationsPage extends StatefulWidget {
  const InvitationsPage({super.key});

  @override
  State<InvitationsPage> createState() => _InvitationsPageState();
}

class _InvitationsPageState extends State<InvitationsPage> {
  final SupabaseService _supabaseService = SupabaseService();
  List<User> _invitations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInvitations();
  }

  Future<void> _loadInvitations() async {
    setState(() => _isLoading = true);
    try {
      final List<User> invitations = await _supabaseService.getPendingInvitations();
      if (mounted) {
        setState(() {
          _invitations = invitations;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _respond(String requesterId, String status) async {
    try {
      await _supabaseService.respondToConnectionRequest(requesterId, status);
      _loadInvitations();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

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
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _invitations.isEmpty
              ? const Center(child: Text('No pending invitations', style: TextStyle(color: Colors.grey, fontSize: 16)))
              : ListView.separated(
                  itemCount: _invitations.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final inv = _invitations[index];
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
                            onPressed: () => _respond(inv.id, 'rejected'),
                          ),
                          IconButton(
                            icon: const Icon(Icons.check_circle, color: Color(0xFF0A66C2), size: 32),
                            onPressed: () => _respond(inv.id, 'accepted'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
