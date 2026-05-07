import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:flutter/foundation.dart';
import 'package:rimlink/models/data_models.dart';

class SupabaseService {
  final sb.SupabaseClient _client = sb.Supabase.instance.client;

  // --- Auth Helpers ---
  sb.User? get currentAuthUser => _client.auth.currentUser;

  String? get currentUserId => _client.auth.currentUser?.id;

  // --- Profile Logic ---
  Future<User?> getCurrentUserProfile() async {
    final id = currentUserId;
    if (id == null) return null;

    final data = await _client
        .from('profiles')
        .select()
        .eq('id', id)
        .single();
    
    return User.fromMap(data);
  }

  Future<User?> getProfileById(String id) async {
    final data = await _client
        .from('profiles')
        .select()
        .eq('id', id)
        .single();
    
    return User.fromMap(data);
  }

  Future<void> updateProfile(User user) async {
    await _client
        .from('profiles')
        .update(user.toMap())
        .eq('id', user.id);
  }

  Future<void> updateProfileField(String field, String value) async {
    final userId = currentUserId;
    if (userId == null) return;
    await _client.from('profiles').update({field: value}).eq('id', userId);
  }

  Future<String> uploadImage(String path, List<int> bytes) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final storagePath = 'public/$fileName';
    
    await _client.storage.from('rimlink').uploadBinary(
      storagePath,
      Uint8List.fromList(bytes),
      fileOptions: const sb.FileOptions(contentType: 'image/jpeg', upsert: true),
    );

    final String publicUrl = _client.storage.from('rimlink').getPublicUrl(storagePath);
    return publicUrl;
  }

  // --- Post Logic ---
  Future<List<Post>> getPosts() async {
    final userId = currentUserId;
    // Select posts and join with profiles (author) and post_likes (for current user)
    var query = _client
        .from('posts')
        .select('*, author:profiles!author_id(*), post_likes(user_id), comments(count)');
    
    if (userId != null) {
      query = query.eq('post_likes.user_id', userId);
    }
    
    final List<dynamic> data = await query.order('created_at', ascending: false);

    return data.map<Post>((json) {
      final author = User.fromMap(json['author']);
      final likes = json['post_likes'] as List;
      final isLiked = likes.isNotEmpty;
      return Post.fromMap(json, author, isLiked: isLiked);
    }).toList();
  }

  Future<void> createPost(String content, {List<String> imageUrls = const []}) async {
    final userId = currentUserId;
    if (userId == null) return;

    await _client.from('posts').insert({
      'author_id': userId,
      'content': content,
      'image_urls': imageUrls,
    });
  }

  Future<List<Post>> getUserPosts(String userId) async {
    final currentUserId = this.currentUserId;
    final List<dynamic> data = await _client
        .from('posts')
        .select('*, author:profiles!author_id(*), post_likes(user_id), comments(count)')
        .eq('author_id', userId)
        .order('created_at', ascending: false);

    return data.map<Post>((json) {
      final author = User.fromMap(json['author']);
      final likes = json['post_likes'] as List;
      final isLiked = currentUserId != null && likes.any((l) => l['user_id'] == currentUserId);
      return Post.fromMap(json, author, isLiked: isLiked);
    }).toList();
  }

  Future<void> updatePostContent(String postId, String content) async {
    await _client
        .from('posts')
        .update({'content': content})
        .eq('id', postId);
  }

  Future<void> deletePost(String postId) async {
    await _client
        .from('posts')
        .delete()
        .eq('id', postId);
  }

  Future<void> toggleLike(String postId, bool currentlyLiked) async {
    final userId = currentUserId;
    if (userId == null) return;

    if (currentlyLiked) {
      // Unlike: Remove row from post_likes and decrement count (SQL handles count usually via triggers or we do it here)
      await _client
          .from('post_likes')
          .delete()
          .match({'post_id': postId, 'user_id': userId});
      
      // Manual decrement for now (Better done via RPC or DB Trigger)
      await _client.rpc('decrement_likes', params: {'post_id': postId});
    } else {
      // Like
      try {
        await _client.from('post_likes').insert({
          'post_id': postId,
          'user_id': userId,
        });
        await _client.rpc('increment_likes', params: {'post_id': postId});
      } catch (e) {
        // Ignore duplicate like exceptions to prevent crashing
      }
    }
  }

  // --- Network/Connections Logic ---
  Future<List<User>> getPeopleYouMayKnow() async {
    final userId = currentUserId;
    if (userId == null) return [];

    // 1. Get all user IDs involved in any connection with the current user
    final List<dynamic> connections = await _client
        .from('connections')
        .select('requester_id, receiver_id')
        .or('requester_id.eq.$userId,receiver_id.eq.$userId');

    final List<String> excludedIds = [userId];
    for (var conn in connections) {
      excludedIds.add(conn['requester_id']);
      excludedIds.add(conn['receiver_id']);
    }

    // 2. Get profiles not in the excluded list
    final List<dynamic> data = await _client
        .from('profiles')
        .select()
        .not('id', 'in', excludedIds)
        .limit(15);

    return data.map<User>((json) => User.fromMap(json)).toList();
  }

  Future<void> sendConnectionRequest(String targetUserId) async {
    final userId = currentUserId;
    if (userId == null) return;

    await _client.from('connections').insert({
      'requester_id': userId,
      'receiver_id': targetUserId,
      'status': 'pending',
    });
  }

  Future<void> cancelConnectionRequest(String targetUserId) async {
    final userId = currentUserId;
    if (userId == null) return;

    await _client
        .from('connections')
        .delete()
        .match({'requester_id': userId, 'receiver_id': targetUserId});
  }

  Future<List<String>> getSentInvitationIds() async {
    final userId = currentUserId;
    if (userId == null) return [];

    final List<dynamic> data = await _client
        .from('connections')
        .select('receiver_id')
        .eq('requester_id', userId)
        .eq('status', 'pending');
    
    return data.map((json) => json['receiver_id'] as String).toList();
  }

  Future<List<User>> getSentInvitations() async {
    final userId = currentUserId;
    if (userId == null) return [];

    final List<dynamic> data = await _client
        .from('connections')
        .select('*, receiver:profiles!receiver_id(*)')
        .eq('requester_id', userId)
        .eq('status', 'pending');
    
    return data.map<User>((json) => User.fromMap(json['receiver'])).toList();
  }

  Future<List<User>> getConnections() async {
    final userId = currentUserId;
    if (userId == null) return [];

    final List<dynamic> data = await _client
        .from('connections')
        .select('*, requester:profiles!requester_id(*), receiver:profiles!receiver_id(*)')
        .eq('status', 'accepted')
        .or('requester_id.eq.$userId,receiver_id.eq.$userId');
    
    return data.map<User>((json) {
      if (json['requester_id'] == userId) {
        return User.fromMap(json['receiver']);
      } else {
        return User.fromMap(json['requester']);
      }
    }).toList();
  }

  Future<String?> getConnectionStatus(String targetUserId) async {
    final userId = currentUserId;
    if (userId == null) return null;

    try {
      final List<dynamic> data = await _client
          .from('connections')
          .select('status, requester_id')
          .or('and(requester_id.eq.$userId,receiver_id.eq.$targetUserId),and(requester_id.eq.$targetUserId,receiver_id.eq.$userId)')
          .limit(1);

      if (data == null || data.isEmpty) return null;
      
      final String status = data[0]['status'];
      final String requesterId = data[0]['requester_id'];
      
      if (status == 'accepted') return 'accepted';
      
      if (status == 'pending') {
        return requesterId == userId ? 'sent' : 'received';
      }
      
      return status;
    } catch (e) {
      debugPrint('Error getting connection status: $e');
      return null;
    }
  }
  // --- Jobs Logic ---
  Future<List<Map<String, dynamic>>> getJobs() async {
    final List<dynamic> data = await _client
        .from('jobs')
        .select()
        .order('created_at', ascending: false);
    
    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<String>> getSavedJobIds() async {
    final userId = currentUserId;
    if (userId == null) return [];

    final List<dynamic> data = await _client
        .from('saved_jobs')
        .select('job_id')
        .eq('user_id', userId);
    
    return data.map((json) => json['job_id'] as String).toList();
  }

  Future<void> toggleSaveJob(String jobId, bool currentlySaved) async {
    final userId = currentUserId;
    if (userId == null) return;

    if (currentlySaved) {
      await _client
          .from('saved_jobs')
          .delete()
          .match({'job_id': jobId, 'user_id': userId});
    } else {
      await _client.from('saved_jobs').insert({
        'job_id': jobId,
        'user_id': userId,
      });
    }
  }

  // --- Comments Logic ---
  Future<List<Map<String, dynamic>>> getComments(String postId) async {
    final List<dynamic> data = await _client
        .from('comments')
        .select('*, author:profiles!author_id(*)')
        .eq('post_id', postId)
        .order('created_at', ascending: true);
    
    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> addComment(String postId, String content) async {
    final userId = currentUserId;
    if (userId == null) return;

    await _client.from('comments').insert({
      'post_id': postId,
      'author_id': userId,
      'content': content,
    });
  }

  // --- Connection Requests Logic ---
  Future<List<User>> getPendingInvitations() async {
    final userId = currentUserId;
    if (userId == null) return [];

    final List<dynamic> data = await _client
        .from('connections')
        .select('*, requester:profiles!requester_id(*)')
        .eq('receiver_id', userId)
        .eq('status', 'pending');
    
    return data.map<User>((json) => User.fromMap(json['requester'])).toList();
  }

  Future<void> respondToConnectionRequest(String requesterId, String status) async {
    final userId = currentUserId;
    if (userId == null) return;

    await _client
        .from('connections')
        .update({'status': status})
        .match({'requester_id': requesterId, 'receiver_id': userId});
  }

  Future<void> changePassword(String newPassword) async {
    await _client.auth.updateUser(
      sb.UserAttributes(password: newPassword),
    );
  }
}
