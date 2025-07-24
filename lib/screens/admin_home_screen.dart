import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        authProvider.logout();
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildAdminTile(
            context: context,
            icon: Icons.hiking,
            title: 'Manage Treks',
            onTap: () {
              // TODO: Navigate to trek management screen
            },
          ),
          _buildAdminTile(
            context: context,
            icon: Icons.assignment,
            title: 'TIMS Bookings',
            onTap: () {
              // TODO: Navigate to TIMS management screen
            },
          ),
          _buildAdminTile(
            context: context,
            icon: Icons.people,
            title: 'Users',
            onTap: () {
              // TODO: Navigate to user management screen
            },
          ),
          _buildAdminTile(
            context: context,
            icon: Icons.emergency,
            title: 'SOS Requests',
            onTap: () {
              // TODO: Navigate to SOS management screen
            },
          ),
          _buildAdminTile(
            context: context,
            icon: Icons.format_list_bulleted,
            title: 'Posts',
            onTap: () {
              // TODO: Navigate to post management screen
            },
          ),
          _buildAdminTile(
            context: context,
            icon: Icons.analytics,
            title: 'Analytics',
            onTap: () {
              // TODO: Navigate to analytics screen
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdminTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
