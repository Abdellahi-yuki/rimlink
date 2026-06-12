import 'package:flutter/material.dart';
import 'package:rimlink/l10n/app_localizations.dart';
import 'package:rimlink/ui/feed/feed_page.dart';
import 'package:rimlink/ui/network/network_page.dart';
import 'package:rimlink/ui/profile/profile_page.dart';
import 'package:rimlink/ui/jobs/jobs_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const FeedPage(),
    const NetworkPage(),
    const JobsPage(),
    const ProfilePage(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        onTap: _onTabTapped,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_filled),
            label: AppLocalizations.of(context)!.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.people_alt),
            label: AppLocalizations.of(context)!.myNetwork,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.business_center),
            label: AppLocalizations.of(context)!.jobs,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: AppLocalizations.of(context)!.me,
          ),
        ],
      ),
    );
  }
}
