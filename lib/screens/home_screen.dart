// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:neptrek/providers/auth_provider.dart';
import 'package:neptrek/providers/trek_provider.dart';
import 'package:neptrek/screens/profile_screen.dart';
import 'package:neptrek/screens/posts_screen.dart';
import 'package:neptrek/screens/home_content.dart';
import 'package:neptrek/screens/sos_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Fetch treks when the home screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final trekProvider = Provider.of<TrekProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      trekProvider.refreshData(authProvider.token);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          HomeContent(),
          PostsScreen(),
          SOSScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: 'Posts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emergency),
            label: 'SOS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        unselectedItemColor: Colors.black87, // Dark color for inactive items
        selectedItemColor: Colors.amber[800], // Keep the amber color for active items
        showUnselectedLabels: true, // Show labels for inactive items
        type: BottomNavigationBarType.fixed, // Ensures all labels are visible
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
