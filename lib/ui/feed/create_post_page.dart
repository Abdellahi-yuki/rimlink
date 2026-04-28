import 'package:flutter/material.dart';
import 'package:rimlink/data/mock_data.dart';
import 'package:rimlink/models/data_models.dart';

class CreatePostPage extends StatefulWidget {
  final String? initialContent;
  
  const CreatePostPage({super.key, this.initialContent});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialContent);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _post() {
    if (_controller.text.trim().isNotEmpty) {
      final newPost = Post(
        id: 'p_${DateTime.now().millisecondsSinceEpoch}',
        author: MockData.currentUser,
        timeAgo: 'Just now',
        content: _controller.text.trim(),
        likesCount: 0,
        comments: [],
      );
      MockData.posts.insert(0, newPost);
      Navigator.pop(context, true); // true indicates successful post
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Share post'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
               if (_controller.text.trim().isNotEmpty) {
                  _post();
               }
            },
            child: const Text('Post', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.blueAccent,
                  child: Text(
                    MockData.currentUser.name.substring(0, 1),
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  MockData.currentUser.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  hintText: 'What do you want to talk about?',
                  border: InputBorder.none,
                ),
                onChanged: (text) {
                  setState(() {}); // to update the Post button color if needed
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
