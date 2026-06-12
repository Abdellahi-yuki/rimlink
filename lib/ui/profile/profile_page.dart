import 'package:image_picker/image_picker.dart';
import 'package:rimlink/models/data_models.dart';
import 'package:flutter/material.dart';
import 'package:rimlink/data/supabase_service.dart';
import 'package:rimlink/ui/widgets/post_widget.dart';
import 'package:rimlink/ui/widgets/full_screen_image_viewer.dart';
import 'package:rimlink/ui/feed/post_detail_page.dart';
import 'package:rimlink/ui/profile/settings_page.dart';

class ProfilePage extends StatefulWidget {
  final User? user;
  const ProfilePage({super.key, this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final SupabaseService _supabaseService = SupabaseService();
  User? _profileUser;
  bool _isLoading = true;
  List<Post> _userPosts = [];
  List<Map<String, dynamic>> _experiences = [];
  List<Map<String, dynamic>> _educations = [];
  String? _connectionStatus; // 'sent', 'received', 'accepted', or null
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickAndUploadImage(bool isAvatar) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image == null) return;

    setState(() => _isLoading = true);
    try {
      final bytes = await image.readAsBytes();
      final String publicUrl = await _supabaseService.uploadImage(image.path, bytes);
      
      final field = isAvatar ? 'avatar_url' : 'banner_url';
      await _supabaseService.updateProfileField(field, publicUrl);
      
      setState(() {
        if (isAvatar) {
          _profileUser?.avatarUrl = publicUrl;
        } else {
          _profileUser?.bannerUrl = publicUrl;
        }
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image: $e')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    if (widget.user != null) {
      _profileUser = await _supabaseService.getProfileById(widget.user!.id);
    } else {
      _profileUser = await _supabaseService.getCurrentUserProfile();
    }
    
    if (_profileUser != null) {
      // Load experiences
      final experiences = await _supabaseService.getExperiences(_profileUser!.id);
      if (mounted) {
        setState(() {
          _experiences = experiences;
        });
      }
      
      // Load educations
      final educations = await _supabaseService.getEducations(_profileUser!.id);
      if (mounted) {
        setState(() {
          _educations = educations;
        });
      }
      
      // Load contact info
      final contactInfo = await _supabaseService.getContactInfo(_profileUser!.id);
      if (mounted) {
        setState(() {
          _profileUser = User(
            id: _profileUser!.id,
            name: _profileUser!.name,
            title: _profileUser!.title,
            location: _profileUser!.location,
            about: _profileUser!.about,
            experience: _profileUser!.experience,
            education: _profileUser!.education,
            skills: _profileUser!.skills,
            connections: _profileUser!.connections,
            isOpenToWork: _profileUser!.isOpenToWork,
            isHiring: _profileUser!.isHiring,
            isProvidingServices: _profileUser!.isProvidingServices,
            avatarUrl: _profileUser!.avatarUrl,
            bannerUrl: _profileUser!.bannerUrl,
            email: contactInfo?['email'],
            phone: contactInfo?['phone'],
          );
        });
      }
      
      await Future.wait([
        _loadPosts(),
        _supabaseService.getConnectionStatus(_profileUser!.id).then((status) {
          if (mounted) setState(() => _connectionStatus = status);
        }),
      ]);
    }
    
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loadPosts() async {
    if (_profileUser == null) return;
    final posts = await _supabaseService.getUserPosts(_profileUser!.id);
    if (mounted) {
      setState(() {
        _userPosts = posts;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_profileUser != null) {
      await _supabaseService.updateProfile(_profileUser!);
    }
  }

  void _showPostOptions(Post post) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit post'),
            onTap: () {
              Navigator.pop(context);
              _editPostDialog(post);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete post', style: TextStyle(color: Colors.red)),
            onTap: () async {
              Navigator.pop(context);
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete post'),
                  content: const Text('Are you sure you want to delete this post?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                  ],
                ),
              );
              if (confirm == true) {
                await _supabaseService.deletePost(post.id);
                _loadPosts();
              }
            },
          ),
        ],
      ),
    );
  }

  void _editPostDialog(Post post) {
    final controller = TextEditingController(text: post.content);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Post'),
        content: TextField(
          controller: controller,
          maxLines: null,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await _supabaseService.updatePostContent(post.id, controller.text);
              _loadPosts();
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

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
            onPressed: () async {
              onSave(controller.text);
              await _saveProfile();
              if (mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _editContactInfoDialog() {
    final emailController = TextEditingController(text: _profileUser?.email ?? '');
    final phoneController = TextEditingController(text: _profileUser?.phone ?? '');
    bool isEmailPublic = false;
    bool isPhonePublic = false;

    // Fetch current privacy settings
    _supabaseService.getContactInfo(_profileUser!.id).then((contactInfo) {
      if (contactInfo != null) {
        isEmailPublic = contactInfo['is_email_public'] ?? false;
        isPhonePublic = contactInfo['is_phone_public'] ?? false;
        if (mounted) setState(() {});
      }
    });

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Contact Info', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Checkbox(
                      value: isEmailPublic,
                      onChanged: (val) => setState(() => isEmailPublic = val ?? false),
                    ),
                    const Text('Make email public'),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Checkbox(
                      value: isPhonePublic,
                      onChanged: (val) => setState(() => isPhonePublic = val ?? false),
                    ),
                    const Text('Make phone public'),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final contactData = {
                    'email': emailController.text.trim().isEmpty ? null : emailController.text.trim(),
                    'phone': phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
                    'is_email_public': isEmailPublic,
                    'is_phone_public': isPhonePublic,
                  };

                  await _supabaseService.updateContactInfo(_profileUser!.id, contactData);
                  await _loadProfile();
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Contact info updated successfully')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error updating contact info: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
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
                _editExperienceDialog(null);
              }
            ),
            ListTile(
              leading: const Icon(Icons.school), 
              title: const Text('Add education'), 
              onTap: () {
                Navigator.pop(context);
                _editEducationDialog(null);
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

  void _editEducationDialog(Map<String, dynamic>? education) {
    final schoolController = TextEditingController(text: education?['school'] ?? '');
    final degreeController = TextEditingController(text: education?['degree'] ?? '');
    final fieldOfStudyController = TextEditingController(text: education?['field_of_study'] ?? '');
    final startDateController = TextEditingController(text: education?['start_date'] ?? '');
    final endDateController = TextEditingController(text: education?['end_date'] ?? '');
    final descriptionController = TextEditingController(text: education?['description'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(education == null ? 'Add Education' : 'Edit Education', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: schoolController,
                decoration: const InputDecoration(
                  labelText: 'School',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: degreeController,
                decoration: const InputDecoration(
                  labelText: 'Degree (e.g., Bachelor of Science)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: fieldOfStudyController,
                decoration: const InputDecoration(
                  labelText: 'Field of Study (e.g., Computer Science)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: startDateController,
                decoration: const InputDecoration(
                  labelText: 'Start Date (e.g., Jan 2020)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: endDateController,
                decoration: const InputDecoration(
                  labelText: 'End Date (optional, e.g., Jan 2024 or leave blank if ongoing)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (schoolController.text.trim().isNotEmpty && startDateController.text.trim().isNotEmpty) {
                final educationData = {
                  'school': schoolController.text.trim(),
                  'degree': degreeController.text.trim().isEmpty ? null : degreeController.text.trim(),
                  'field_of_study': fieldOfStudyController.text.trim().isEmpty ? null : fieldOfStudyController.text.trim(),
                  'start_date': startDateController.text.trim(),
                  'end_date': endDateController.text.trim().isEmpty ? null : endDateController.text.trim(),
                  'description': descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim(),
                };

                if (education == null) {
                  await _supabaseService.addEducation(_profileUser!.id, educationData);
                } else {
                  await _supabaseService.updateEducation(education['id'], educationData);
                }

                _loadProfile();
                if (mounted) Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _editExperienceDialog(Map<String, dynamic>? experience) {
    final titleController = TextEditingController(text: experience?['title'] ?? '');
    final companyController = TextEditingController(text: experience?['company'] ?? '');
    final locationController = TextEditingController(text: experience?['location'] ?? '');
    final startDateController = TextEditingController(text: experience?['start_date'] ?? '');
    final endDateController = TextEditingController(text: experience?['end_date'] ?? '');
    final descriptionController = TextEditingController(text: experience?['description'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(experience == null ? 'Add Experience' : 'Edit Experience', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Job Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: companyController,
                decoration: const InputDecoration(
                  labelText: 'Company',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: startDateController,
                decoration: const InputDecoration(
                  labelText: 'Start Date (e.g., Jan 2020)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: endDateController,
                decoration: const InputDecoration(
                  labelText: 'End Date (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.trim().isNotEmpty && companyController.text.trim().isNotEmpty) {
                final experienceData = {
                  'title': titleController.text.trim(),
                  'company': companyController.text.trim(),
                  'location': locationController.text.trim(),
                  'start_date': startDateController.text.trim(),
                  'end_date': endDateController.text.trim().isEmpty ? null : endDateController.text.trim(),
                  'description': descriptionController.text.trim(),
                };

                if (experience == null) {
                  await _supabaseService.addExperience(_profileUser!.id, experienceData);
                } else {
                  await _supabaseService.updateExperience(experience['id'], experienceData);
                }

                _loadProfile();
                if (mounted) Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
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
              onTap: () async {
                setState(() {
                  displayUser.isOpenToWork = !displayUser.isOpenToWork;
                  if (displayUser.isOpenToWork) {
                    displayUser.isHiring = false;
                    displayUser.isProvidingServices = false;
                  }
                });
                await _saveProfile();
                if (mounted) Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(displayUser.isHiring ? 'Remove "Hiring"' : 'Hiring', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Share that you are hiring and attract qualified candidates'),
              onTap: () async {
                setState(() {
                  displayUser.isHiring = !displayUser.isHiring;
                  if (displayUser.isHiring) {
                    displayUser.isOpenToWork = false;
                    displayUser.isProvidingServices = false;
                  }
                });
                await _saveProfile();
                if (mounted) Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(displayUser.isProvidingServices ? 'Remove "Providing services"' : 'Providing services', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Showcase services you offer so new clients can discover you'),
              onTap: () async {
                setState(() {
                  displayUser.isProvidingServices = !displayUser.isProvidingServices;
                  if (displayUser.isProvidingServices) {
                    displayUser.isOpenToWork = false;
                    displayUser.isHiring = false;
                  }
                });
                await _saveProfile();
                if (mounted) Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showContactInfoModal(User displayUser, bool isOwner, [Map<String, dynamic>? contactInfo]) async {
    // Fetch contact info if not provided
    contactInfo ??= await _supabaseService.getContactInfo(displayUser.id);
    final bool isEmailPublic = contactInfo?['is_email_public'] ?? false;
    final bool isPhonePublic = contactInfo?['is_phone_public'] ?? false;
    
    debugPrint('Contact info in modal: $contactInfo');
    debugPrint('Is email public: $isEmailPublic, Is phone public: $isPhonePublic');

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(displayUser.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                if (isOwner)
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.grey),
                    onPressed: () {
                      Navigator.pop(context);
                      _editContactInfoDialog();
                    },
                  ),
              ],
            ),
            const SizedBox(height: 16),

            if (displayUser.email != null && displayUser.email!.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.email, color: Colors.grey),
                title: const Text('Email'),
                subtitle: Text(displayUser.email!),
                trailing: isOwner
                  ? IconButton(
                      icon: Icon(
                        isEmailPublic ? Icons.visibility : Icons.visibility_off,
                        color: isEmailPublic ? Colors.green : Colors.grey,
                      ),
                      onPressed: () async {
                        final updatedContactInfo = {
                          'is_email_public': !isEmailPublic,
                        };
                        await _supabaseService.updateContactInfo(displayUser.id, updatedContactInfo);
                        if (mounted) {
                          Navigator.pop(context);
                          _showContactInfoModal(displayUser, isOwner);
                        }
                      },
                    )
                  : null,
              ),
            if (displayUser.phone != null && displayUser.phone!.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.phone, color: Colors.grey),
                title: const Text('Phone'),
                subtitle: Text(displayUser.phone!),
                trailing: isOwner
                  ? IconButton(
                      icon: Icon(
                        isPhonePublic ? Icons.visibility : Icons.visibility_off,
                        color: isPhonePublic ? Colors.green : Colors.grey,
                      ),
                      onPressed: () async {
                        final updatedContactInfo = {
                          'is_phone_public': !isPhonePublic,
                        };
                        await _supabaseService.updateContactInfo(displayUser.id, updatedContactInfo);
                        if (mounted) {
                          Navigator.pop(context);
                          _showContactInfoModal(displayUser, isOwner);
                        }
                      },
                    )
                  : null,
              ),
            if ((displayUser.email == null || displayUser.email!.isEmpty || (!isOwner && !isEmailPublic)) && 
                (displayUser.phone == null || displayUser.phone!.isEmpty || (!isOwner && !isPhonePublic)))
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text('No contact information available', style: TextStyle(color: Colors.grey)),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
    if (_profileUser == null) {
      return const Scaffold(body: Center(child: Text('Profile not found.')));
    }

    final displayUser = _profileUser!;
    final isOwner = displayUser.id == _supabaseService.currentUserId;
    // For now, connections is simplified. Real logic would query 'connections' table.
    final isPending = false; 

    return Scaffold(
      backgroundColor: Colors.grey[300], 
      appBar: AppBar(
        title: Text(displayUser.name, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
                _loadProfile();
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
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.blueGrey[700],
                          image: displayUser.bannerUrl != null
                            ? DecorationImage(image: NetworkImage(displayUser.bannerUrl!), fit: BoxFit.cover)
                            : null,
                        ),
                        child: displayUser.bannerUrl == null
                          ? const Center(child: Icon(Icons.wallpaper, color: Colors.white54, size: 48))
                          : null,
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
                                              onTap: () async {
                                                final contactInfo = await _supabaseService.getContactInfo(displayUser.id);
                                                if (mounted) {
                                                  _showContactInfoModal(displayUser, isOwner, contactInfo);
                                                }
                                              },
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
                                  if (_connectionStatus == 'accepted')
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: null, // Disabled as there's no messaging system
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.grey,
                                          side: const BorderSide(color: Colors.grey),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                        ),
                                        child: const Text('Connected'),
                                      ),
                                    )
                                  else if (_connectionStatus == 'sent')
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () async {
                                          await _supabaseService.cancelConnectionRequest(displayUser.id);
                                          setState(() => _connectionStatus = null);
                                        },
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.grey[700],
                                          side: BorderSide(color: Colors.grey[400]!),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                        ),
                                        child: const Text('Pending'),
                                      ),
                                    )
                                  else if (_connectionStatus == 'received')
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          await _supabaseService.respondToConnectionRequest(displayUser.id, 'accepted');
                                          setState(() => _connectionStatus = 'accepted');
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Theme.of(context).primaryColor,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                        ),
                                        child: const Text('Accept'),
                                      ),
                                    )
                                  else
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          await _supabaseService.sendConnectionRequest(displayUser.id);
                                          setState(() => _connectionStatus = 'sent');
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Theme.of(context).primaryColor,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                        ),
                                        child: const Text('Connect'),
                                      ),
                                    ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton(
                                       onPressed: () => _showContactInfoModal(displayUser, isOwner),
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
                      child: InkWell(
                        onTap: () => _pickAndUploadImage(false),
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 16,
                          child: Icon(Icons.camera_alt, color: Theme.of(context).primaryColor, size: 18),
                        ),
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
                            backgroundColor: Colors.primaries[displayUser.name.length % Colors.primaries.length],
                            backgroundImage: displayUser.avatarUrl != null ? NetworkImage(displayUser.avatarUrl!) : null,
                            child: displayUser.avatarUrl == null
                              ? Text(
                                  displayUser.name.substring(0, 1),
                                  style: const TextStyle(fontSize: 48, color: Colors.white, fontWeight: FontWeight.bold),
                                )
                              : null,
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
                            child: InkWell(
                              onTap: () => _pickAndUploadImage(true),
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 16,
                                child: Icon(Icons.add_circle, color: Theme.of(context).primaryColor, size: 32),
                              ),
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
                    displayUser.about.isEmpty ? (isOwner ? "Add your summary here." : "Nothing in the About section") : displayUser.about,
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
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () => _showAddSectionModal(displayUser),
                            ),
                          ],
                        )
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Display experiences from the new experiences table
                  if (_experiences.isNotEmpty)
                    ..._experiences.map((exp) => Column(
                      children: [
                        _buildExperienceItem(exp, isOwner),
                        const SizedBox(height: 16),
                        if (_experiences.last != exp) const Divider(),
                      ],
                    )).toList(),
                  
                  if (_experiences.isEmpty && isOwner)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'No experience added yet.',
                        style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Education Section
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
                          icon: const Icon(Icons.add),
                          onPressed: () => _editEducationDialog(null),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_educations.isNotEmpty)
                    ..._educations.map((edu) => Column(
                      children: [
                        _buildEducationItem(edu, isOwner),
                        if (_educations.last != edu) const Divider(),
                      ],
                    )).toList(),
                  if (_educations.isEmpty && isOwner)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'No education added yet.',
                        style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
                      ),
                    ),
                ],
              ),
            ),

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
                    if (isOwner)
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
            
            // Activity Section
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Activity', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('${_userPosts.length} posts', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  if (_userPosts.isEmpty)
                    const Text('No posts yet.', style: TextStyle(color: Colors.grey))
                  else
                    ..._userPosts.map((post) => PostWidget(
                      post: post,
                      showMenu: isOwner,
                      onMenuPressed: () => _showPostOptions(post),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => PostDetailPage(post: post)),
                        );
                        _loadPosts();
                      },
                      onProfileTap: () {
                        // Already on profile page, maybe just scroll to top?
                        // Or do nothing if it's the same user.
                      },
                    )),
                ],
              ),
            ),
            
            // Bottom Padding
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // Helper widget to render education items
  Widget _buildEducationItem(Map<String, dynamic> education, bool isOwner) {
    return Row(
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    education['school'] ?? 'Unknown School',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  if (isOwner)
                    PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      icon: Icon(Icons.more_vert, size: 16, color: Colors.grey[600]),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit', style: TextStyle(fontSize: 14)),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete', style: TextStyle(fontSize: 14, color: Colors.red)),
                        ),
                      ],
                      onSelected: (value) async {
                        if (value == 'edit') {
                          _editEducationDialog(education);
                        } else if (value == 'delete') {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete education'),
                              content: const Text('Are you sure you want to delete this education?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await _supabaseService.deleteEducation(education['id']);
                            _loadProfile();
                          }
                        }
                      },
                    ),
                ],
              ),
              if (education['degree'] != null && education['degree'].isNotEmpty)
                Text(
                  education['degree'],
                  style: const TextStyle(fontSize: 14),
                ),
              if (education['field_of_study'] != null && education['field_of_study'].isNotEmpty)
                Text(
                  education['field_of_study'],
                  style: const TextStyle(fontSize: 14),
                ),
              Text(
                '${education['start_date'] ?? 'Unknown'} - ${education['end_date'] ?? 'Present'}',
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 8),
              if (education['description'] != null && education['description'].isNotEmpty)
                Text(
                  education['description'],
                  style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper widget to render experience items
  Widget _buildExperienceItem(Map<String, dynamic> experience, bool isOwner) {
    return Row(
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(experience['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  if (isOwner)
                    PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      icon: Icon(Icons.more_vert, size: 16, color: Colors.grey[600]),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit', style: TextStyle(fontSize: 14)),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete', style: TextStyle(fontSize: 14, color: Colors.red)),
                        ),
                      ],
                      onSelected: (value) async {
                        if (value == 'edit') {
                          _editExperienceDialog(experience);
                        } else if (value == 'delete') {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete experience'),
                              content: const Text('Are you sure you want to delete this experience?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await _supabaseService.deleteExperience(experience['id']);
                            _loadProfile();
                          }
                        }
                      },
                    ),
                ],
              ),
              Text(experience['company'], style: const TextStyle(fontSize: 14)),
              Text(
                '${experience['start_date']} - ${experience['end_date'] ?? 'Present'}',
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              if (experience['location'] != null && experience['location'].isNotEmpty)
                Text(experience['location'], style: const TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 8),
              if (experience['description'] != null && experience['description'].isNotEmpty)
                Text(
                  experience['description'],
                  style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black),
                ),
            ],
          ),
        ),
      ],
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

