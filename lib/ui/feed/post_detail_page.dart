import 'package:flutter/material.dart';
import 'package:rimlink/data/supabase_service.dart';
import 'package:rimlink/models/data_models.dart';
import 'package:rimlink/ui/widgets/full_screen_image_viewer.dart';
import 'package:rimlink/ui/profile/profile_page.dart';

class PostDetailPage extends StatefulWidget {
  final Post post;

  const PostDetailPage({super.key, required this.post});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final SupabaseService _supabaseService = SupabaseService();
  late TextEditingController _commentController;
  List<Comment> _comments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
    _loadComments();
  }

  Future<void> _loadComments() async {
    setState(() => _isLoading = true);
    try {
      final commentsData = await _supabaseService.getComments(widget.post.id);
      if (mounted) {
        setState(() {
          _comments = commentsData.map((c) {
            final author = User.fromMap(c['author']);
            return Comment.fromMap(c, author);
          }).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isNotEmpty) {
      final content = _commentController.text.trim();
      _commentController.clear();
      FocusScope.of(context).unfocus();
      
      try {
        await _supabaseService.addComment(widget.post.id, content);
        _loadComments();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error posting comment: $e')),
          );
        }
      }
    }
  }

   void _editCommentDialog(Comment comment) {
     final controller = TextEditingController(text: comment.content);
     showDialog(
       context: context,
       builder: (context) => AlertDialog(
         title: const Text('Edit Comment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
         content: TextField(
           controller: controller,
           maxLines: 3,
           decoration: const InputDecoration(
             border: OutlineInputBorder(),
             hintText: 'Edit your comment',
           ),
         ),
         actions: [
           TextButton(
             onPressed: () => Navigator.pop(context),
             child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
           ),
           ElevatedButton(
             onPressed: () async {
               if (controller.text.trim().isNotEmpty) {
                 try {
                   await _supabaseService.updateComment(comment.id, controller.text.trim());
                   
                   // Update the comment in the local list immediately
                   setState(() {
                     final index = _comments.indexWhere((c) => c.id == comment.id);
                     if (index != -1) {
                       _comments[index] = Comment(
                         id: comment.id,
                         author: comment.author,
                         content: controller.text.trim(),
                         createdAt: comment.createdAt,
                       );
                     }
                   });
                   
                   if (mounted) {
                     Navigator.pop(context);
                     ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(content: Text('Comment updated successfully')),
                     );
                   }
                 } catch (e) {
                   if (mounted) {
                     Navigator.pop(context);
                     ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}')),
                     );
                   }
                 }
               }
             },
             style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
             child: const Text('Save', style: TextStyle(color: Colors.white)),
           ),
         ],
       ),
     );
   }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Post'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Full Post
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => ProfilePage(user: post.author)),
                                );
                              },
                                child: CircleAvatar(
                                  radius: 24,
                                  backgroundColor: Colors.primaries[post.author.name.length % Colors.primaries.length],
                                  backgroundImage: post.author.avatarUrl != null ? NetworkImage(post.author.avatarUrl!) : null,
                                  child: post.author.avatarUrl == null
                                    ? Text(
                                        post.author.name.substring(0, 1),
                                        style: const TextStyle(color: Colors.white, fontSize: 20),
                                      )
                                    : null,
                                ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    post.author.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  Text(
                                    post.author.title,
                                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        '${post.timeAgo} • ',
                                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                      ),
                                      Icon(Icons.public, color: Colors.grey[600], size: 12),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          post.content,
                          style: const TextStyle(fontSize: 16),
                        ),
                        if (post.imageUrls.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: SizedBox(
                              height: 300,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: post.imageUrls.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => FullScreenImageViewer(
                                              imageUrls: post.imageUrls,
                                              initialIndex: index,
                                            ),
                                          ),
                                        );
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          post.imageUrls[index],
                                          height: 300,
                                          width: post.imageUrls.length == 1 ? MediaQuery.of(context).size.width - 32 : 300,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),
                        const Divider(height: 1, thickness: 1),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildActionButton(
                              icon: post.isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                              label: 'Like',
                              color: post.isLiked ? const Color(0xFF0A66C2) : Colors.grey[600]!,
                              onTap: () async {
                                final wasLiked = post.isLiked;
                                setState(() {
                                  post.isLiked = !wasLiked;
                                  post.likesCount += wasLiked ? -1 : 1;
                                });

                                try {
                                  await _supabaseService.toggleLike(post.id, wasLiked);
                                } catch (e) {
                                  setState(() {
                                    post.isLiked = wasLiked;
                                    post.likesCount += wasLiked ? 1 : -1;
                                  });
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error toggling like: $e')),
                                    );
                                  }
                                }
                              },
                            ),
                            _buildActionButton(
                              icon: Icons.comment_outlined,
                              label: 'Comment',
                              onTap: () {
                                // Focus the comment field
                                FocusScope.of(context).requestFocus(FocusNode());
                              },
                            ),
                            _buildActionButton(
                              icon: Icons.repeat,
                              label: 'Repost',
                              onTap: () {},
                            ),
                          ],
                        ),
                        const Divider(height: 1, thickness: 1),
                      ],
                    ),
                  ),
                  
                  // Comments Section
                  _isLoading 
                    ? const Center(child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ))
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _comments.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final comment = _comments[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => ProfilePage(user: comment.author)),
                                    );
                                  },
                                  child: CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Colors.primaries[comment.author.name.length % Colors.primaries.length],
                                    backgroundImage: comment.author.avatarUrl != null ? NetworkImage(comment.author.avatarUrl!) : null,
                                    child: comment.author.avatarUrl == null
                                      ? Text(comment.author.name.substring(0, 1), style: const TextStyle(color: Colors.white, fontSize: 12))
                                      : null,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: const BorderRadius.only(
                                        topRight: Radius.circular(8),
                                        bottomLeft: Radius.circular(8),
                                        bottomRight: Radius.circular(8),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => ProfilePage(user: comment.author)),
                                                );
                                              },
                                              child: Text(comment.author.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                            ),
                                            Row(
                                              children: [
                                                Text(comment.timeAgo, style: TextStyle(color: Colors.grey[600], fontSize: 10)),
                                                const SizedBox(width: 8),
                                                if (comment.author.id == SupabaseService().currentUserId)
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
                                                        _editCommentDialog(comment);
                                                      } else if (value == 'delete') {
                                                        final confirm = await showDialog<bool>(
                                                          context: context,
                                                          builder: (context) => AlertDialog(
                                                            title: const Text('Delete comment'),
                                                            content: const Text('Are you sure you want to delete this comment?'),
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
                                                          await _supabaseService.deleteComment(comment.id);
                                                          _loadComments();
                                                        }
                                                      }
                                                    },
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Text(comment.author.title, style: TextStyle(color: Colors.grey[600], fontSize: 10)),
                                        const SizedBox(height: 8),
                                        Text(comment.content, style: const TextStyle(fontSize: 14)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                ],
              ),
            ),
          ),
          
          // Comment Input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Leave a comment',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.send, color: Theme.of(context).primaryColor),
                    onPressed: _addComment,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          children: [
            Icon(icon, color: color ?? Colors.grey[600], size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: color ?? Colors.grey[600], fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
