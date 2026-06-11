import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.text = widget.initialQuery;
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
          decoration: const InputDecoration(
            hintText: 'Search posts or people...',
            border: InputBorder.none,
          ),
          onSubmitted: _performSearch,
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          indicatorColor: Theme.of(context).primaryColor,
          tabs: const [
            Tab(text: 'People'),
            Tab(text: 'Posts'),
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
      return const Center(child: Text('No people found.'));
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
              child: const Text('View Profile'),
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
        );
      },
    );
  }
}
