import 'package:flutter/material.dart';
import 'package:rimlink/ui/widgets/post_widget.dart';
import 'package:rimlink/ui/widgets/full_screen_image_viewer.dart';
import 'package:rimlink/ui/profile/profile_page.dart';
import 'package:rimlink/ui/feed/create_post_page.dart';
import 'package:rimlink/ui/feed/search_page.dart';
import 'package:rimlink/ui/feed/post_detail_page.dart';
import 'package:rimlink/data/supabase_service.dart';
import 'package:rimlink/models/data_models.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final SupabaseService _supabaseService = SupabaseService();
  List<Post> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshPosts();
  }

  Future<void> _refreshPosts() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final posts = await _supabaseService.getPosts();
      if (mounted) {
        setState(() {
          _posts = posts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading posts: $e')),
        );
      }
    }
  }

  // Navigation helper that refreshes the page upon return
  Future<void> _navigateAndRefresh(BuildContext context, Widget page) async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => page));
    _refreshPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300], 
      appBar: AppBar(
        title: SizedBox(
          height: 36,
          child: TextField(
            readOnly: true,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchPage())),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search, size: 20, color: Colors.black54),
              hintText: 'Search',
              hintStyle: TextStyle(fontSize: 14),
              contentPadding: EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(4)),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Color(0xFFEEF3F8),
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
      body: RefreshIndicator(
        onRefresh: _refreshPosts,
        child: _isLoading && _posts.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : _posts.isEmpty
                ? const Center(child: Text('No posts yet. Be the first to share something!'))
                : ListView.builder(
                    itemCount: _posts.length,
                    itemBuilder: (context, index) {
                      final post = _posts[index];
                      return PostWidget(
                        post: post,
                        onTap: () => _navigateAndRefresh(context, PostDetailPage(post: post)),
                        onProfileTap: () => _navigateAndRefresh(context, ProfilePage(user: post.author)),
                        onRepost: () async {
                          try {
                            await _supabaseService.repostPost(post.id);
                            _refreshPosts();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Post reposted')),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          }
                        },
                      );
                    },
                  ),
      ),
    );
  }
}
