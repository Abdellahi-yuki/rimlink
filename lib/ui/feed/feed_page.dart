import 'package:flutter/material.dart';
import 'package:rimlink/data/mock_data.dart';
import 'package:rimlink/ui/profile/profile_page.dart';
import 'package:rimlink/ui/feed/create_post_page.dart';
import 'package:rimlink/ui/feed/post_detail_page.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  // Navigation helper that refreshes the page upon return
  Future<void> _navigateAndRefresh(BuildContext context, Widget page) async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => page));
    setState(() {}); // refresh likes/comments
  }

  @override
  Widget build(BuildContext context) {
    final posts = MockData.posts;

    return Scaffold(
      backgroundColor: Colors.grey[300], // Background color similar to LinkedIn
      appBar: AppBar(
        title: const SizedBox(
          height: 36,
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search, size: 20, color: Colors.black54),
              hintText: 'Search',
              hintStyle: TextStyle(fontSize: 14),
              contentPadding: EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(4)),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Color(0xFFEEF3F8), // LinkedIn search bar background
            ),
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () => _navigateAndRefresh(context, const ProfilePage()),
            child: CircleAvatar(
              backgroundColor: Colors.grey[400],
              child: const Icon(Icons.person, color: Colors.white),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Create a post', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              onPressed: () => _navigateAndRefresh(context, const CreatePostPage()),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return Container(
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () => _navigateAndRefresh(context, PostDetailPage(post: post)),
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
                          InkWell(
                            onTap: () => _navigateAndRefresh(context, ProfilePage(user: post.author)),
                            child: CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.primaries[post.author.name.length % Colors.primaries.length],
                              child: Text(
                                post.author.name.substring(0, 1),
                                style: const TextStyle(color: Colors.white, fontSize: 20),
                              ),
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
                          IconButton(
                            icon: const Icon(Icons.more_horiz, color: Colors.grey),
                            onPressed: () {},
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
                            '${post.comments.length} comments',
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
                          onTap: () {
                            setState(() {
                              post.isLiked = !post.isLiked;
                              post.likesCount += post.isLiked ? 1 : -1;
                            });
                          },
                        ),
                        _buildActionButton(
                          icon: Icons.comment_outlined,
                          label: 'Comment',
                          onTap: () => _navigateAndRefresh(context, PostDetailPage(post: post)),
                        ),
                        _buildActionButton(
                          icon: Icons.repeat,
                          label: 'Repost',
                          onTap: () => _navigateAndRefresh(
                            context,
                            CreatePostPage(initialContent: 'Reposting ${post.author.name}:\n\n${post.content}'),
                          ),
                        ),
                        _buildActionButton(
                          icon: Icons.copy,
                          label: 'Copy link',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Link copied to clipboard!')),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
