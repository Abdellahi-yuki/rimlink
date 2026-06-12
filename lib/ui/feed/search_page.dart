import 'package:flutter/material.dart';
import 'package:rimlink/l10n/app_localizations.dart';
import 'package:rimlink/data/supabase_service.dart';
import 'package:rimlink/models/data_models.dart';
import 'package:rimlink/ui/widgets/post_widget.dart';
import 'package:rimlink/ui/profile/profile_page.dart';
import 'package:rimlink/ui/feed/post_detail_page.dart';

class SearchPage extends StatefulWidget {
  final String initialQuery;
  const SearchPage({super.key, this.initialQuery = ''});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final SupabaseService _supabaseService = SupabaseService();
  
  List<User> _userResults = [];
  List<Post> _postResults = [];
  bool _isLoading = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.text = widget.initialQuery;
    _currentUserId = _supabaseService.currentUserId;
    if (widget.initialQuery.isNotEmpty) {
      _performSearch(widget.initialQuery);
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;
    
    setState(() => _isLoading = true);
    
    try {
      final results = await Future.wait([
        _supabaseService.searchUsers(query),
        _supabaseService.searchPosts(query),
      ]);
      
      if (mounted) {
        setState(() {
          _userResults = results[0] as List<User>;
          _postResults = results[1] as List<Post>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
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
                setState(() => _postResults.removeWhere((p) => p.id == post.id));
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
          decoration: const InputDecoration(hintText: 'Write something...'),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              await _supabaseService.updatePostContent(post.id, controller.text.trim());
              if (context.mounted) Navigator.pop(context);
              _performSearch(_searchController.text);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: TextField(
          controller: _searchController,
          autofocus: widget.initialQuery.isEmpty,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.searchHint,
            border: InputBorder.none,
          ),
          onSubmitted: _performSearch,
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          indicatorColor: Theme.of(context).primaryColor,
          tabs: [
            Tab(text: AppLocalizations.of(context)!.peopleYouMayKnow),
            Tab(text: AppLocalizations.of(context)!.postDetail),
          ],
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : TabBarView(
            controller: _tabController,
            children: [
              _buildUserResults(),
              _buildPostResults(),
            ],
          ),
    );
  }

  Widget _buildUserResults() {
    if (_userResults.isEmpty) {
      return Center(child: Text(AppLocalizations.of(context)!.noPeopleFound));
    }
    return ListView.builder(
      itemCount: _userResults.length,
      itemBuilder: (context, index) {
        final user = _userResults[index];
        return Container(
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 1),
          child: ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage(user: user)),
              );
            },
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.primaries[user.name.length % Colors.primaries.length],
              backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
              child: user.avatarUrl == null
                ? Text(user.name.substring(0, 1), style: const TextStyle(color: Colors.white))
                : null,
            ),
            title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(user.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage(user: user)),
                );
              },
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: Text(AppLocalizations.of(context)!.viewProfile),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPostResults() {
    if (_postResults.isEmpty) {
      return const Center(child: Text('No posts found.'));
    }
    return ListView.builder(
      itemCount: _postResults.length,
      itemBuilder: (context, index) {
        final post = _postResults[index];
        return PostWidget(
          post: post,
          showMenu: post.author.id == _currentUserId,
          onMenuPressed: post.author.id == _currentUserId ? () => _showPostOptions(post) : null,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PostDetailPage(post: post)),
            );
          },
          onProfileTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage(user: post.author)),
            );
          },
          onRepost: () async {
            try {
              await _supabaseService.repostPost(post.id);
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
    );
  }
}
