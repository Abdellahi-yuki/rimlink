class User {
  final String id;
  String name;
  String title;
  final String location;
  String about;
  String experience;
  String education;
  String skills;
  final int connections;
  bool isOpenToWork;
  bool isHiring;
  bool isProvidingServices;
  String? avatarUrl;
  String? bannerUrl;

  User({
    required this.id,
    required this.name,
    required this.title,
    required this.location,
    required this.about,
    required this.experience,
    this.education = '',
    this.skills = '',
    this.isOpenToWork = false,
    this.isHiring = false,
    this.isProvidingServices = false,
    required this.connections,
    this.avatarUrl,
    this.bannerUrl,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'] ?? 'Unknown',
      title: map['title'] ?? '',
      location: map['location'] ?? '',
      about: map['about'] ?? '',
      experience: map['experience'] ?? '',
      education: map['education'] ?? '',
      skills: map['skills'] ?? '',
      connections: map['connections'] ?? 0,
      isOpenToWork: map['is_open_to_work'] ?? false,
      isHiring: map['is_hiring'] ?? false,
      isProvidingServices: map['is_providing_services'] ?? false,
      avatarUrl: map['avatar_url'],
      bannerUrl: map['banner_url'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'title': title,
      'location': location,
      'about': about,
      'experience': experience,
      'education': education,
      'skills': skills,
      'is_open_to_work': isOpenToWork,
      'is_hiring': isHiring,
      'is_providing_services': isProvidingServices,
      'avatar_url': avatarUrl,
      'banner_url': bannerUrl,
    };
  }
}

class Comment {
  final String id;
  final User author;
  final String content;
  final DateTime createdAt;

  const Comment({
    required this.id,
    required this.author,
    required this.content,
    required this.createdAt,
  });

  factory Comment.fromMap(Map<String, dynamic> map, User author) {
    return Comment(
      id: map['id'],
      author: author,
      content: map['content'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : DateTime.now(),
    );
  }

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inDays > 7) return '${(diff.inDays / 7).floor()}w';
    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return 'Now';
  }
}

class Post {
  final String id;
  final User author;
  final DateTime createdAt;
  final String content;
  int likesCount;
  bool isLiked;
  final int commentsCount;
  final List<String> imageUrls;

  Post({
    required this.id,
    required this.author,
    required this.createdAt,
    required this.content,
    required this.likesCount,
    this.isLiked = false,
    required this.commentsCount,
    this.imageUrls = const [],
  });

  factory Post.fromMap(Map<String, dynamic> map, User author, {bool isLiked = false}) {
    // Check for nested count from Supabase: comments(count) returns [{count: X}]
    int cCount = 0;
    if (map['comments'] != null && map['comments'] is List && (map['comments'] as List).isNotEmpty) {
      cCount = map['comments'][0]['count'] ?? 0;
    }

    return Post(
      id: map['id'],
      author: author,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : DateTime.now(),
      content: map['content'],
      likesCount: map['likes_count'] ?? 0,
      isLiked: isLiked,
      commentsCount: cCount,
      imageUrls: List<String>.from(map['image_urls'] ?? []),
    );
  }

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inDays > 7) return '${(diff.inDays / 7).floor()}w';
    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return 'Now';
  }
}

class Job {
  final String id;
  final String title;
  final String company;
  final String location;
  final String description;
  final bool isEasyApply;
  final DateTime createdAt;

  Job({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.description,
    this.isEasyApply = false,
    required this.createdAt,
  });

  factory Job.fromMap(Map<String, dynamic> map) {
    return Job(
      id: map['id'],
      title: map['title'],
      company: map['company'],
      location: map['location'] ?? '',
      description: map['description'] ?? '',
      isEasyApply: map['is_easy_apply'] ?? false,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'company': company,
      'location': location,
      'description': description,
      'is_easy_apply': isEasyApply,
    };
  }

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return 'Just now';
  }
}
