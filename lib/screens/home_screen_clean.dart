// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:neptrek/providers/auth_provider.dart';
import 'package:neptrek/providers/trek_provider.dart';
import 'package:neptrek/models/trek_model.dart';
import 'package:neptrek/screens/trek_details_screen.dart';
import 'package:neptrek/screens/interests_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('NepTrek'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authProvider.logout();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logged out successfully!')),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(authProvider.user?.displayName ?? authProvider.user?.user.username ?? 'Guest'),
              accountEmail: Text(authProvider.user?.user.email ?? 'No email'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  authProvider.user?.displayName?[0].toUpperCase() ??
                  authProvider.user?.user.username[0].toUpperCase() ??
                  'G',
                  style: const TextStyle(fontSize: 40.0),
                ),
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('My Interests'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const InterestsScreen(),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                authProvider.logout();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logged out successfully!')),
                );
              },
            ),
          ],
        ),
      ),
      body: Consumer2<TrekProvider, AuthProvider>(
        builder: (context, trekProvider, authProvider, child) {
          return RefreshIndicator(
            onRefresh: () => trekProvider.refreshData(authProvider.token),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Section
                  _buildWelcomeSection(authProvider),
                  const SizedBox(height: 24),
                  
                  // All Treks Section
                  _buildTreksSection(trekProvider),
                  const SizedBox(height: 32),
                  
                  // Recommended Treks Section
                  _buildRecommendedSection(trekProvider, authProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeSection(AuthProvider authProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade400,
            Colors.blue.shade600,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back,',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            authProvider.user?.displayName ?? authProvider.user?.user.username ?? 'User',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Discover amazing treks in Nepal',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTreksSection(TrekProvider trekProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Popular Treks',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (trekProvider.isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: 16),
        
        if (trekProvider.isLoading && trekProvider.treks.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (trekProvider.errorMessage != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        trekProvider.errorMessage!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: trekProvider.fetchTreks,
                  child: const Text('Retry'),
                ),
              ],
            ),
          )
        else if (trekProvider.treks.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text(
                'No treks available',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          )
        else
          SizedBox(
            height: 280,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: trekProvider.treks.length,
              itemBuilder: (context, index) {
                final trek = trekProvider.treks[index];
                return _buildTrekCard(trek);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildRecommendedSection(TrekProvider trekProvider, AuthProvider authProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              authProvider.isAuthenticated && authProvider.hasSetInterests
                  ? 'Recommended for You'
                  : 'Featured Treks',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (trekProvider.isLoadingRecommended)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        if (authProvider.isAuthenticated && authProvider.hasSetInterests)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              'Based on your interests',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
        const SizedBox(height: 16),
        
        if (trekProvider.isLoadingRecommended && trekProvider.recommendedTreks.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (trekProvider.recommendedErrorMessage != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_outlined, color: Colors.orange.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    trekProvider.recommendedErrorMessage!,
                    style: TextStyle(color: Colors.orange.shade700),
                  ),
                ),
              ],
            ),
          )
        else if (trekProvider.recommendedTreks.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text(
                'No recommended treks available',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          )
        else
          SizedBox(
            height: 280,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: trekProvider.recommendedTreks.length,
              itemBuilder: (context, index) {
                final trek = trekProvider.recommendedTreks[index];
                return _buildTrekCard(trek, isRecommended: true);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildTrekCard(Trek trek, {bool isRecommended = false}) {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TrekDetailsScreen(
                  trekId: trek.id,
                  trekName: trek.name,
                ),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Trek Image
              Container(
                height: 150,
                width: double.infinity,
                child: Stack(
                  children: [
                    trek.photos.isNotEmpty
                        ? Image.network(
                            trek.photos.first,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 150,
                                color: Colors.grey.shade300,
                                child: const Icon(
                                  Icons.landscape,
                                  color: Colors.grey,
                                  size: 50,
                                ),
                              );
                            },
                          )
                        : Container(
                            height: 150,
                            color: Colors.grey.shade300,
                            child: const Icon(
                              Icons.landscape,
                              color: Colors.grey,
                              size: 50,
                            ),
                          ),
                    if (isRecommended)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Recommended',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              // Trek Details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trek.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        trek.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${trek.duration} days',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              Text(
                                '${trek.difficulty}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        //   Text(
                        //     '\$${trek.cost.toStringAsFixed(0)}',
                        //     style: const TextStyle(
                        //       fontSize: 16,
                        //       fontWeight: FontWeight.bold,
                        //       color: Colors.green,
                        //     ),
                        //   ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
