import 'package:rimlink/models/data_models.dart';

class MockData {
  static User currentUser = User(
    id: 'u1',
    name: 'Yuki Dev',
    title: 'Full-Stack Developer | Mobile & Web Solutions | Passionate about UI/UX',
    location: 'Tokyo, Japan',
    about: 'Experienced software engineer with a strong track record of designing, developing, and deploying scalable web and mobile applications. Enthusiastic about creating user-centric solutions using Flutter, React, and modern backend technologies.',
    experience: 'Leading the frontend development team to build cross-platform mobile experiences with Flutter. Increased app performance by 30% and introduced robust state management architectures.',
    connections: 543,
  );

  static List<User> suggestedUsers = [
    User(
      id: 'u2',
      name: 'Sarah Jenkins',
      title: 'Senior Software Engineer | Flutter Specialist',
      location: 'San Francisco, CA',
      about: 'Flutter developer building performant mobile experiences.',
      experience: 'Senior developer leading mobile architecture.',
      connections: 1104,
    ),
    User(
      id: 'u3',
      name: 'David Chen',
      title: 'Product Manager at TechFlow',
      location: 'New York, NY',
      about: 'Building products that people love.',
      experience: 'Product strategy and team execution.',
      connections: 890,
    ),
    User(
      id: 'u4',
      name: 'Elena Rodriguez',
      title: 'UI/UX Designer',
      location: 'London, UK',
      about: 'Designing beautiful and intuitive interfaces.',
      experience: 'Lead designer for top FinTech applications.',
      connections: 612,
    ),
    User(
      id: 'u5',
      name: 'Michael Barnes',
      title: 'DevOps Engineer',
      location: 'Austin, TX',
      about: 'Automating everything from tests to deployments.',
      experience: 'CI/CD pipeline wizardry.',
      connections: 450,
    ),
  ];

  static List<User> invitations = [
    User(
      id: 'i1',
      name: 'Alex Johnson',
      title: 'Software Engineer at Google',
      location: 'California, US',
      about: 'Building search algorithms.',
      experience: 'Google Search Team',
      connections: 112,
    ),
    User(
      id: 'i2',
      name: 'Maria Garcia',
      title: 'HR Manager',
      location: 'Madrid, Spain',
      about: 'Helping teams grow.',
      experience: 'Talent Acquisition',
      connections: 840,
    ),
  ];

  static Set<String> pendingConnections = {};

  static List<Post> posts = [
      Post(
        id: 'p1',
        author: suggestedUsers[0], // Sarah Jenkins
        timeAgo: '2h',
        content: 'Just completed a huge refactoring using Riverpod. The performance gains are incredible! Always keep learning. 🚀 #Flutter #MobileDev',
        likesCount: 142,
        comments: [
          Comment(
            id: 'c1',
            author: suggestedUsers[1],
            content: 'That sounds amazing! Do you recommend Riverpod over Provider?',
            timeAgo: '1h',
          ),
        ],
      ),
      Post(
        id: 'p2',
        author: suggestedUsers[1], // David Chen
        timeAgo: '5h',
        content: 'We are hiring! Looking for talented designers who want to build the next generation of productivity tools. Message me for details.',
        likesCount: 89,
        comments: [],
      ),
      Post(
        id: 'p3',
        author: suggestedUsers[2], // Elena Rodriguez
        timeAgo: '1d',
        content: 'Design is not just what it looks like and feels like. Design is how it works. Spent the weekend redesigning some classic app interfaces.',
        likesCount: 310,
        comments: [
          Comment(
            id: 'c2',
            author: currentUser,
            content: 'Great quote! UI/UX is truly the foundation of any application.',
            timeAgo: '10h',
          ),
        ],
      ),
      Post(
        id: 'p4',
        author: suggestedUsers[3], // Michael Barnes
        timeAgo: '2d',
        content: 'If you are not automating your deployments, what are you even doing? CI/CD pipelines have saved me countless hours this year.',
        likesCount: 225,
        comments: [],
      ),
    ];
}
