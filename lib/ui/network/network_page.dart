import 'package:flutter/material.dart';
import 'package:rimlink/data/supabase_service.dart';
import 'package:rimlink/models/data_models.dart';
import 'package:rimlink/ui/profile/profile_page.dart';
import 'package:rimlink/ui/network/invitations_page.dart';

class NetworkPage extends StatefulWidget {
  const NetworkPage({super.key});

  @override
  State<NetworkPage> createState() => _NetworkPageState();
}

class _NetworkPageState extends State<NetworkPage> {
  final SupabaseService _supabaseService = SupabaseService();
  List<User> _suggestions = [];
  List<User> _sentInvitations = [];
  List<User> _connections = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final results = await Future.wait([
      _supabaseService.getPeopleYouMayKnow(),
      _supabaseService.getSentInvitations(),
      _supabaseService.getConnections(),
    ]);
    
    if (mounted) {
      setState(() {
        _suggestions = results[0] as List<User>;
        _sentInvitations = results[1] as List<User>;
        _connections = results[2] as List<User>;
        _isLoading = false;
      });
    }
  }

  Future<void> _cancelInvitation(User user) async {
    try {
      await _supabaseService.cancelConnectionRequest(user.id);
      setState(() {
        _sentInvitations.removeWhere((u) => u.id == user.id);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invitation to ${user.name} cancelled')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _sendInvitation(User user) async {
    try {
      await _supabaseService.sendConnectionRequest(user.id);
      setState(() {
        _suggestions.removeWhere((u) => u.id == user.id);
        _sentInvitations.add(user);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invitation sent to ${user.name}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: CustomScrollView(
                slivers: [
                  // Manage network header
                  SliverToBoxAdapter(
                    child: InkWell(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const InvitationsPage()),
                        );
                        _loadData();
                      },
                      child: Container(
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Manage my network',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                            ),
                            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[600]),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Sent Invitations Section
                  if (_sentInvitations.isNotEmpty) ...[
                    _buildSectionHeader('Sent invitations (${_sentInvitations.length})'),
                    SliverToBoxAdapter(
                      child: Container(
                        height: 190,
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: _sentInvitations.length,
                          itemBuilder: (context, index) {
                            final user = _sentInvitations[index];
                            return _buildSmallUserCard(user, isSent: true);
                          },
                        ),
                      ),
                    ),
                  ],

                  // Connections Section
                  if (_connections.isNotEmpty) ...[
                    _buildSectionHeader('Connections (${_connections.length})'),
                    SliverToBoxAdapter(
                      child: Container(
                        height: 190,
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: _connections.length,
                          itemBuilder: (context, index) {
                            final user = _connections[index];
                            return _buildSmallUserCard(user, isConnection: true);
                          },
                        ),
                      ),
                    ),
                  ],

                  // Suggestions Section
                  _buildSectionHeader('People you may know'),
                  SliverPadding(
                    padding: const EdgeInsets.all(12),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 0.68,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final user = _suggestions[index];
                          return _buildFullUserCard(user);
                        },
                        childCount: _suggestions.length,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSmallUserCard(User user, {bool isSent = false, bool isConnection = false}) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage(user: user)),
        );
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: Colors.primaries[user.name.length % Colors.primaries.length],
              backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
              child: user.avatarUrl == null
                ? Text(user.name.substring(0, 1), style: const TextStyle(color: Colors.white, fontSize: 24))
                : null,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                user.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isSent)
              TextButton(
                onPressed: () => _cancelInvitation(user),
                style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                child: const Text('Cancel', style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
              )
            else if (isConnection)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text('Connected', style: TextStyle(color: Colors.grey, fontSize: 11)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullUserCard(User user) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage(user: user)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          children: [
            // Banner & Avatar Stack
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[100],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                    image: user.bannerUrl != null ? DecorationImage(image: NetworkImage(user.bannerUrl!), fit: BoxFit.cover) : null,
                  ),
                ),
                Positioned(
                  top: 25,
                  left: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 38,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.primaries[user.name.length % Colors.primaries.length],
                      backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                      child: user.avatarUrl == null
                        ? Text(user.name.substring(0, 1), style: const TextStyle(color: Colors.white, fontSize: 24))
                        : null,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.title,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: OutlinedButton(
                onPressed: () => _sendInvitation(user),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 32),
                  side: BorderSide(color: Theme.of(context).primaryColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('Connect', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
