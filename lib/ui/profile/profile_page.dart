import 'package:flutter/material.dart';
import 'package:rimlink/models/data_models.dart';
import 'package:rimlink/data/mock_data.dart';
import 'package:rimlink/ui/profile/settings_page.dart';

class ProfilePage extends StatefulWidget {
  final User? user;
  const ProfilePage({super.key, this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Helpers for editing text fields
  void _editFieldDialog(String title, String initialValue, Function(String) onSave) {
    final controller = TextEditingController(text: initialValue);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $title', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              onSave(controller.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddSectionModal(User displayUser) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add to profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.work), 
              title: const Text('Add experience'), 
              onTap: () {
                Navigator.pop(context);
                _editFieldDialog('Experience', displayUser.experience, (val) => setState(() => displayUser.experience = val));
              }
            ),
            ListTile(
              leading: const Icon(Icons.school), 
              title: const Text('Add education'), 
              onTap: () {
                Navigator.pop(context);
                _editFieldDialog('Education', displayUser.education, (val) => setState(() => displayUser.education = val));
              }
            ),
            ListTile(
              leading: const Icon(Icons.build), 
              title: const Text('Add skills'), 
              onTap: () {
                Navigator.pop(context);
                _editFieldDialog('Skills', displayUser.skills, (val) => setState(() => displayUser.skills = val));
              }
            ),
          ],
        ),
      ),
    );
  }

  void _showOpenToModal(User displayUser) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Open to', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              title: Text(displayUser.isOpenToWork ? 'Remove "Open to work"' : 'Finding a new job', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Show recruiters and others that you are open to work'),
              onTap: () {
                setState(() {
                  displayUser.isOpenToWork = !displayUser.isOpenToWork;
                  if (displayUser.isOpenToWork) {
                    displayUser.isHiring = false;
                    displayUser.isProvidingServices = false;
                  }
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(displayUser.isHiring ? 'Remove "Hiring"' : 'Hiring', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Share that you are hiring and attract qualified candidates'),
              onTap: () {
                setState(() {
                  displayUser.isHiring = !displayUser.isHiring;
                  if (displayUser.isHiring) {
                    displayUser.isOpenToWork = false;
                    displayUser.isProvidingServices = false;
                  }
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(displayUser.isProvidingServices ? 'Remove "Providing services"' : 'Providing services', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Showcase services you offer so new clients can discover you'),
              onTap: () {
                setState(() {
                  displayUser.isProvidingServices = !displayUser.isProvidingServices;
                  if (displayUser.isProvidingServices) {
                    displayUser.isOpenToWork = false;
                    displayUser.isHiring = false;
                  }
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showContactInfoModal(User displayUser) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(displayUser.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const ListTile(
              leading: Icon(Icons.link, color: Colors.grey),
              title: Text('Your Profile'),
              subtitle: Text('linkedin.com/in/dummy-profile'),
            ),
            const ListTile(
              leading: Icon(Icons.email, color: Colors.grey),
              title: Text('Email'),
              subtitle: Text('Hidden per privacy settings'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayUser = widget.user ?? MockData.currentUser;
    final isOwner = displayUser.id == MockData.currentUser.id;
    final isPending = MockData.pendingConnections.contains(displayUser.id);

    return Scaffold(
      backgroundColor: Colors.grey[300], // LinkedIn background style
      appBar: AppBar(
        title: Text(displayUser.name, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Profile Card
            Container(
              color: Colors.white,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Banner Image
                      Container(
                        height: 120,
                        color: Colors.blueGrey[700],
                        child: const Center(
                          child: Icon(Icons.wallpaper, color: Colors.white54, size: 48),
                        ),
                      ),
                      // Details under banner
                      Padding(
                        padding: const EdgeInsets.only(top: 60, left: 16, right: 16, bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        displayUser.name,
                                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        displayUser.title,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Text(
                                            displayUser.location,
                                            style: const TextStyle(color: Colors.grey, fontSize: 14),
                                          ),
                                          const SizedBox(width: 8),
                                          InkWell(
                                            onTap: () => _showContactInfoModal(displayUser),
                                            child: const Text(
                                              'Contact info',
                                              style: TextStyle(color: Color(0xFF0A66C2), fontWeight: FontWeight.bold, fontSize: 14),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        '${displayUser.connections}+ connections',
                                        style: const TextStyle(color: Color(0xFF0A66C2), fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isOwner)
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.grey),
                                    onPressed: () {
                                      _editFieldDialog('Title', displayUser.title, (newVal) {
                                        setState(() => displayUser.title = newVal);
                                      });
                                    },
                                  )
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // Action Buttons based on ownership
                            Row(
                              children: [
                                if (isOwner) ...[
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => _showOpenToModal(displayUser),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context).primaryColor,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      ),
                                      child: const Text('Open to'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => _showAddSectionModal(displayUser),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Theme.of(context).primaryColor,
                                        side: BorderSide(color: Theme.of(context).primaryColor),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      ),
                                      child: const Text('Add section'),
                                    ),
                                  ),
                                ] else ...[
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          if (isPending) {
                                            MockData.pendingConnections.remove(displayUser.id);
                                          } else {
                                            MockData.pendingConnections.add(displayUser.id);
                                          }
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isPending ? Colors.grey[300] : Theme.of(context).primaryColor,
                                        foregroundColor: isPending ? Colors.black54 : Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      ),
                                      child: Text(isPending ? 'Pending' : 'Connect'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => _showContactInfoModal(displayUser),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Theme.of(context).primaryColor,
                                        side: BorderSide(color: Theme.of(context).primaryColor),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      ),
                                      child: const Text('Contact info'),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  // Edit background button - Owner only
                  if (isOwner)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 16,
                        child: Icon(Icons.camera_alt, color: Theme.of(context).primaryColor, size: 18),
                      ),
                    ),
                    
                  // Profile Picture
                  Positioned(
                    top: 60,
                    left: 16,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.blueAccent,
                            child: Text(
                              displayUser.name.substring(0, 1),
                              style: const TextStyle(fontSize: 48, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        if (displayUser.isOpenToWork)
                          _buildBadgeBanner('#OPENTOWORK', Colors.green)
                        else if (displayUser.isHiring)
                          _buildBadgeBanner('#HIRING', Colors.purple)
                        else if (displayUser.isProvidingServices)
                          _buildBadgeBanner('PROVIDING SERVICES', Colors.blueGrey),
                        if (isOwner)
                          Positioned(
                            bottom: 0,
                            right: -5,
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 16,
                              child: Icon(Icons.add_circle, color: Theme.of(context).primaryColor, size: 32),
                            ),
                          )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // About Section
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'About',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      if (isOwner)
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.grey),
                          onPressed: () {
                            _editFieldDialog('About', displayUser.about, (newVal) {
                              setState(() => displayUser.about = newVal);
                            });
                          },
                        )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    displayUser.about.isEmpty ? "Add your summary here." : displayUser.about,
                    style: TextStyle(fontSize: 14, height: 1.5, color: displayUser.about.isEmpty ? Colors.grey : Colors.black),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Experience Section
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Experience',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      if (isOwner)
                        Row(
                          children: [
                            IconButton(icon: const Icon(Icons.add), onPressed: () => _showAddSectionModal(displayUser)),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.grey),
                              onPressed: () {
                                _editFieldDialog('Experience', displayUser.experience, (newVal) {
                                  setState(() => displayUser.experience = newVal);
                                });
                              },
                            ),
                          ],
                        )
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        color: Colors.grey[300],
                        child: const Icon(Icons.business, color: Colors.grey),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Current Position', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text(displayUser.title, style: const TextStyle(fontSize: 14)),
                            const Text('Jan 2021 - Present • 3 yrs 4 mos', style: TextStyle(color: Colors.grey, fontSize: 14)),
                            Text(displayUser.location, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                            const SizedBox(height: 8),
                            Text(
                              displayUser.experience.isEmpty ? 'No experience details available.' : displayUser.experience,
                              style: TextStyle(fontSize: 14, height: 1.5, color: displayUser.experience.isEmpty ? Colors.grey : Colors.black),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Education Section (Conditional)
            if (displayUser.education.isNotEmpty) ...[
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Education', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        if (isOwner)
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.grey),
                            onPressed: () {
                              _editFieldDialog('Education', displayUser.education, (newVal) {
                                setState(() => displayUser.education = newVal);
                              });
                            },
                          )
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          color: Colors.grey[300],
                          child: const Icon(Icons.school, color: Colors.grey),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('University / College', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text(displayUser.education, style: const TextStyle(fontSize: 14)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Skills Section (Conditional)
            if (displayUser.skills.isNotEmpty) ...[
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Skills', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        if (isOwner)
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.grey),
                                onPressed: () {
                                  _editFieldDialog('Skills', displayUser.skills, (newVal) {
                                    setState(() => displayUser.skills = newVal);
                                  });
                                },
                              )
                            ],
                          )
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      displayUser.skills,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    const Row(
                      children: [
                        Icon(Icons.people, size: 16, color: Colors.grey),
                        SizedBox(width: 8),
                        Text('Endorsed by multiple connections', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            
            // Bottom Padding
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // Helper widget to render styled bottom badges overlapping the avatar
  Widget _buildBadgeBanner(String text, Color color) {
    return Positioned(
      bottom: -5,
      left: -8,
      right: -8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

