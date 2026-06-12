class ContactInfo {
  String? email;
  String? phone;

  ContactInfo({this.email, this.phone});

  factory ContactInfo.fromMap(Map<String, dynamic> map) {
    return ContactInfo(
      email: map['email'],
      phone: map['phone'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'phone': phone,
    };
  }
}

class Experience {
  String id;
  String title;
  String company;
  String location;
  String startDate;
  String? endDate;
  String description;

  Experience({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.startDate,
    this.endDate,
    required this.description,
  });

  factory Experience.fromMap(Map<String, dynamic> map) {
    return Experience(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      company: map['company'] ?? '',
      location: map['location'] ?? '',
      startDate: map['start_date'] ?? '',
      endDate: map['end_date'],
      description: map['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'company': company,
      'location': location,
      'start_date': startDate,
      'end_date': endDate,
      'description': description,
    };
  }
}

class User {
  final String id;
  final String name;
  String title;
  String location;
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
  String? email;
  String? phone;

  User({
    required this.id,
    required this.name,
    this.title = '',
    this.location = '',
    this.about = '',
    this.experience = '',
    this.education = '',
    this.skills = '',
    this.connections = 0,
    this.isOpenToWork = false,
    this.isHiring = false,
    this.isProvidingServices = false,
    this.avatarUrl,
    this.bannerUrl,
    this.email,
    this.phone,
  });

  User copyWith({
    String? id,
    String? name,
    String? title,
    String? location,
    String? about,
    String? experience,
    String? education,
    String? skills,
    int? connections,
    bool? isOpenToWork,
    bool? isHiring,
    bool? isProvidingServices,
    String? avatarUrl,
    String? bannerUrl,
    String? email,
    String? phone,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      title: title ?? this.title,
      location: location ?? this.location,
      about: about ?? this.about,
      experience: experience ?? this.experience,
      education: education ?? this.education,
      skills: skills ?? this.skills,
      connections: connections ?? this.connections,
      isOpenToWork: isOpenToWork ?? this.isOpenToWork,
      isHiring: isHiring ?? this.isHiring,
      isProvidingServices: isProvidingServices ?? this.isProvidingServices,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }

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
      email: map['email'],
      phone: map['phone'],
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
      'email': email,
      'phone': phone,
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
  final bool isPromoted;
  final String applyLink;
  final String posterId;
  final DateTime createdAt;

  Job({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.description,
    this.isEasyApply = false,
    this.isPromoted = false,
    required this.applyLink,
    required this.posterId,
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
      isPromoted: map['is_promoted'] ?? false,
      applyLink: map['apply_link'] ?? '',
      posterId: map['poster_id'] ?? '',
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
