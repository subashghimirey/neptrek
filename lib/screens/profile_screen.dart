// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:neptrek/providers/auth_provider.dart';
import 'package:neptrek/screens/interests_screen.dart';
import 'package:neptrek/screens/favorites_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              // Show confirmation dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('CANCEL'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        authProvider.logout();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Logged out successfully')),
                        );
                      },
                      child: const Text('LOGOUT'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Profile Header with Avatar
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                // Display Name
                Text(
                  authProvider.user?.displayName ?? authProvider.user?.user.username ?? 'Guest',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Username
                if (authProvider.user?.displayName != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '@${authProvider.user?.user.username}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          // Action Buttons Section
          Card(
            elevation: 1,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                // View Favorites Button
                ListTile(
                  leading: Icon(Icons.favorite, color: theme.colorScheme.primary),
                  title: const Text('View Favorites'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FavoritesScreen(),
                      ),
                    );
                  },
                ),
                Divider(height: 1, color: theme.dividerColor),
                // Update Interests Button
                ListTile(
                  leading: Icon(Icons.interests, color: theme.colorScheme.primary),
                  title: const Text('Update Interests'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const InterestsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          
          // Version info at bottom
          Padding(
            padding: const EdgeInsets.only(top: 24.0),
            child: Center(
              child: Text(
                'NepTrek v1.0.0',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
