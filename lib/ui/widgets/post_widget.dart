import 'package:flutter/material.dart';
import 'package:rimlink/data/supabase_service.dart';
import 'package:rimlink/models/data_models.dart';
import 'package:rimlink/ui/widgets/full_screen_image_viewer.dart';

class PostWidget extends StatefulWidget {
  final Post post;
  final VoidCallback? onTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onMenuPressed;
  final bool showMenu;

  const PostWidget({
    super.key,
    required this.post,
    this.onTap,
    this.onProfileTap,
    this.onMenuPressed,
    this.showMenu = false,
  });

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  final SupabaseService _supabaseService = SupabaseService();

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 0.5,
      color: Colors.white,
      child: InkWell(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Post header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: widget.onProfileTap,
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
                    if (widget.showMenu)
                      IconButton(
                        icon: const Icon(Icons.more_horiz),
                        onPressed: widget.onMenuPressed,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              
              // Post content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  post.content,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              if (post.imageUrls.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: SizedBox(
                    height: 250,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: post.imageUrls.length,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
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
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                post.imageUrls[index],
                                height: 250,
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
              const SizedBox(height: 12),
              
              // Post stats
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.thumb_up, color: post.isLiked ? const Color(0xFF0A66C2) : Colors.grey, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${post.likesCount}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const Spacer(),
                    Text(
                      '${post.commentsCount} comments',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              
              const Divider(height: 24, thickness: 1),
              
              // Action buttons
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
                    color: Colors.grey[600]!,
                    onTap: widget.onTap ?? () {},
                  ),
                  _buildActionButton(
                    icon: Icons.repeat,
                    label: 'Repost',
                    color: Colors.grey[600]!,
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
