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
  });
}

class Comment {
  final String id;
  final User author;
  final String content;
  final String timeAgo;

  const Comment({
    required this.id,
    required this.author,
    required this.content,
    required this.timeAgo,
  });
}

class Post {
  final String id;
  final User author;
  final String timeAgo;
  final String content;
  int likesCount;
  bool isLiked;
  final List<Comment> comments;

  Post({
    required this.id,
    required this.author,
    required this.timeAgo,
    required this.content,
    required this.likesCount,
    this.isLiked = false,
    required this.comments,
  });
}
