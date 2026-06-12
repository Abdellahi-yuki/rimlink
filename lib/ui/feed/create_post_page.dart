import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rimlink/l10n/app_localizations.dart';
import 'package:rimlink/data/supabase_service.dart';
import 'package:rimlink/models/data_models.dart';

class CreatePostPage extends StatefulWidget {
  final String? initialContent;
  
  const CreatePostPage({super.key, this.initialContent});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  late TextEditingController _controller;
  final SupabaseService _supabaseService = SupabaseService();
  final ImagePicker _picker = ImagePicker();
  User? _currentUser;
  final List<XFile> _selectedImages = [];
  bool _isPosting = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialContent);
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _supabaseService.getCurrentUserProfile();
    if (mounted) {
      setState(() {
        _currentUser = user;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage(imageQuality: 70);
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images);
      });
    }
  }

  Future<void> _post() async {
    if (_controller.text.trim().isNotEmpty || _selectedImages.isNotEmpty) {
      setState(() => _isPosting = true);
      try {
        List<String> imageUrls = [];
        for (var image in _selectedImages) {
          final bytes = await image.readAsBytes();
          final url = await _supabaseService.uploadImage(image.path, bytes);
          imageUrls.add(url);
        }
        
        await _supabaseService.createPost(_controller.text.trim(), imageUrls: imageUrls);
        if (mounted) Navigator.pop(context, true);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${AppLocalizations.of(context)!.failedToPost}: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isPosting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.sharePost),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isPosting ? null : _post,
            child: _isPosting 
              ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(AppLocalizations.of(context)!.post, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          )
        ],
      ),
      body: _currentUser == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.primaries[_currentUser!.name.length % Colors.primaries.length],
                        backgroundImage: _currentUser!.avatarUrl != null ? NetworkImage(_currentUser!.avatarUrl!) : null,
                        child: _currentUser!.avatarUrl == null
                          ? Text(
                              _currentUser!.name.substring(0, 1),
                              style: const TextStyle(color: Colors.white, fontSize: 20),
                            )
                          : null,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _currentUser!.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      children: [
                        TextField(
                          controller: _controller,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.whatToTalkAbout,
                            border: InputBorder.none,
                          ),
                          onChanged: (text) {
                            setState(() {}); 
                          },
                        ),
                        if (_selectedImages.isNotEmpty)
                          SizedBox(
                            height: 200,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _selectedImages.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.file(
                                          File(_selectedImages[index].path),
                                          fit: BoxFit.cover,
                                          width: 150,
                                          height: 200,
                                        ),
                                      ),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: GestureDetector(
                                          onTap: () => setState(() => _selectedImages.removeAt(index)),
                                          child: const CircleAvatar(
                                            backgroundColor: Colors.black54,
                                            radius: 12,
                                            child: Icon(Icons.close, color: Colors.white, size: 14),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.image, color: Colors.grey),
                        onPressed: _pickImages,
                      ),
                      IconButton(
                        icon: const Icon(Icons.videocam, color: Colors.grey),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today, color: Colors.grey),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_horiz, color: Colors.grey),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
