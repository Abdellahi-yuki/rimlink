import 'package:flutter/material.dart';
import 'package:rimlink/data/mock_data.dart';
import 'package:rimlink/ui/profile/profile_page.dart';
import 'package:rimlink/ui/network/invitations_page.dart';

class NetworkPage extends StatefulWidget {
  const NetworkPage({super.key});

  @override
  State<NetworkPage> createState() => _NetworkPageState();
}

class _NetworkPageState extends State<NetworkPage> {
  @override
  Widget build(BuildContext context) {
    final invitations = MockData.invitations;
    final suggestions = MockData.suggestedUsers;

    return Scaffold(
      backgroundColor: Colors.grey[300], // matching linkedin grey
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Manage my network header
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Manage my network',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF0A66C2)),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[600]),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Invitations Section
              if (invitations.isNotEmpty)
                Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Invitations', style: TextStyle(fontSize: 16)),
                            InkWell(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const InvitationsPage()),
                                );
                                setState(() {}); // Refresh local list after returning
                              },
                              child: Text(
                                'See all (${invitations.length})',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                              ),
                            )
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: invitations.length > 2 ? 2 : invitations.length, // Preview max 2
                        itemBuilder: (context, index) {
                          final inv = invitations[index];
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
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(inv.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.people, size: 14, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    const Text('3 mutual connections', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                  ],
                                ),
                              ],
                            ),
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
                                    });
                                  },
                                ),
                              ],
                            ),
                            isThreeLine: true,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              if (invitations.isNotEmpty) const SizedBox(height: 8),

              // People you may know
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('People you may know', style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // 2 items per row
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 0.65, // Adjusts card height
                      ),
                      itemCount: suggestions.length,
                      itemBuilder: (context, index) {
                        final sug = suggestions[index];
                        final isPending = MockData.pendingConnections.contains(sug.id);

                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ProfilePage(user: sug)),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    // Banner
                                    Container(
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey[200],
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                      ),
                                    ),
                                    // Avatar
                                    Positioned(
                                      top: 16,
                                      left: 0,
                                      right: 0,
                                      child: CircleAvatar(
                                        radius: 40,
                                        backgroundColor: Colors.white,
                                        child: CircleAvatar(
                                          radius: 36,
                                          backgroundColor: Colors.accents[sug.name.length % Colors.accents.length],
                                          child: Text(sug.name.substring(0, 1), style: const TextStyle(color: Colors.black54, fontSize: 32)),
                                        ),
                                      ),
                                    ),
                                    // Close btn
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            MockData.suggestedUsers.remove(sug);
                                          });
                                        },
                                        child: CircleAvatar(
                                          backgroundColor: Colors.black26,
                                          radius: 12,
                                          child: const Icon(Icons.close, color: Colors.white, size: 16),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 48), // spacer for avatar
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Column(
                                      children: [
                                        Text(
                                          sug.name,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          sug.title,
                                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),
                                        const Text(
                                          'Based on your profile',
                                          style: TextStyle(fontSize: 10, color: Colors.black54),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: OutlinedButton(
                                    onPressed: () {
                                      setState(() {
                                        if (isPending) {
                                          MockData.pendingConnections.remove(sug.id);
                                        } else {
                                          MockData.pendingConnections.add(sug.id);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Connection request sent to ${sug.name}')),
                                          );
                                        }
                                      });
                                    },
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: isPending ? Colors.grey[200] : Colors.white,
                                      foregroundColor: isPending ? Colors.black54 : Theme.of(context).primaryColor,
                                      side: BorderSide(color: isPending ? Colors.grey[300]! : Theme.of(context).primaryColor),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      minimumSize: const Size(double.infinity, 36),
                                    ),
                                    child: Text(
                                      isPending ? 'Pending' : 'Connect',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
