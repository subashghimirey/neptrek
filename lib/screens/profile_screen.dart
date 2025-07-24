// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:neptrek/providers/auth_provider.dart';
import 'package:neptrek/screens/interests_screen.dart';
import 'package:neptrek/screens/favorites_screen.dart';
import 'package:neptrek/screens/tims_list_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

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
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        children: [
          // Profile Header with Avatar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Stack(
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
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
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
                const SizedBox(height: 16),
                // User Stats Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStatColumn('Treks', '12'),
                    Container(
                      height: 40,
                      width: 1,
                      color: Colors.grey.withOpacity(0.3),
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                    ),
                    _buildStatColumn('Alerts', '3'),
                    Container(
                      height: 40,
                      width: 1,
                      color: Colors.grey.withOpacity(0.3),
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                    ),
                    _buildStatColumn('Favorites', '8'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          // Settings and Actions Section
          Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildListTile(
                  icon: Icons.favorite_border,
                  title: 'My Favorites',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FavoritesScreen()),
                  ),
                ),
                const Divider(height: 1),
                _buildListTile(
                  icon: Icons.track_changes,
                  title: 'My Treks',
                  onTap: () {
                    // TODO: Navigate to My Treks screen
                  },
                ),
                const Divider(height: 1),
                _buildListTile(
                  icon: Icons.warning_outlined,
                  title: 'My Alerts',
                  subtitle: '3 active alerts',
                  onTap: () {
                    // TODO: Navigate to My Alerts screen
                  },
                ),
                const Divider(height: 1),
                _buildListTile(
                  icon: Icons.interests,
                  title: 'Interests',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const InterestsScreen()),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Bookings and Permits Section
          Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildListTile(
                  icon: Icons.card_membership,
                  title: 'TIMS Bookings',
                  subtitle: 'View your TIMS permit history',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TimsListScreen()),
                  ),
                ),
                // Add more booking related items here if needed
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Account Settings Section
          Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildListTile(
                  icon: Icons.person_outline,
                  title: 'Edit Profile',
                  subtitle: 'Update your personal information',
                  onTap: () {
                    // TODO: Navigate to Edit Profile screen
                  },
                ),
                const Divider(height: 1),
                _buildListTile(
                  icon: Icons.password,
                  title: 'Change Password',
                  onTap: () {
                    // TODO: Navigate to Change Password screen
                  },
                ),
                const Divider(height: 1),
                _buildListTile(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  onTap: () {
                    // TODO: Navigate to Notifications settings
                  },
                ),
                const Divider(height: 1),
                _buildListTile(
                  icon: Icons.security,
                  title: 'Privacy & Security',
                  onTap: () {
                    // TODO: Navigate to Privacy settings
                  },
                ),
                const Divider(height: 1),
                _buildListTile(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  onTap: () {
                    // TODO: Navigate to Help screen
                  },
                ),
              ],
            ),
          ),
          
          // Version info at bottom
          Padding(
            padding: const EdgeInsets.all(24.0),
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