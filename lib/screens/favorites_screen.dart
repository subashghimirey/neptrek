// lib/screens/favorites_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:neptrek/providers/trek_provider.dart';
import 'package:neptrek/providers/auth_provider.dart';
import 'package:neptrek/screens/trek_details_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final trekProvider = Provider.of<TrekProvider>(context, listen: false);

    setState(() {
      _isLoading = true;
    });

    // First fetch favorites to get the IDs
    await trekProvider.fetchFavorites(authProvider.token);
    
    // Then fetch all treks if they haven't been loaded yet
    if (trekProvider.treks.isEmpty) {
      await trekProvider.fetchTreks();
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final trekProvider = Provider.of<TrekProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Treks'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFavorites,
            tooltip: 'Refresh favorites',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : trekProvider.favoriteIds.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 64,
                        color: theme.colorScheme.primary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No favorite treks yet',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap the heart icon on treks you like',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadFavorites,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: trekProvider.favoriteIds.length,
                    itemBuilder: (context, index) {
                      // Skip treks that are no longer in the list
                      if (!trekProvider.treks.any((trek) => 
                        trek.id.toString() == trekProvider.favoriteIds[index])) {
                        return const SizedBox.shrink();
                      }
                      
                      final trek = trekProvider.treks.firstWhere(
                        (trek) => trek.id.toString() == trekProvider.favoriteIds[index],
                      );

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TrekDetailsScreen(
                                  trekId: trek.id,
                                  trekName: trek.name,
                                ),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              // Trek Image
                              SizedBox(
                                width: 120,
                                height: 120,
                                child: trek.photos.isNotEmpty
                                    ? Image.network(
                                        trek.photos.first,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            color: Colors.grey.shade200,
                                            child: const Icon(
                                              Icons.image_not_supported,
                                              color: Colors.grey,
                                            ),
                                          );
                                        },
                                      )
                                    : Container(
                                        color: Colors.grey.shade200,
                                        child: const Icon(
                                          Icons.landscape,
                                          color: Colors.grey,
                                        ),
                                      ),
                              ),
                              // Trek Info
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
                                        '${trek.region} • ${trek.difficulty}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.schedule,
                                            size: 14,
                                            color: Colors.grey.shade600,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            trek.duration,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Remove from favorites button
                              IconButton(
                                icon: const Icon(Icons.favorite),
                                color: Colors.red,
                                onPressed: () async {
                                  if (authProvider.user?.user.id == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Unable to modify favorites. Please try logging in again.'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                    return;
                                  }
                                  
                                  await trekProvider.toggleFavorite(
                                    trek.id.toString(),
                                    authProvider.token,
                                    userId: authProvider.user!.user.id.toString(),
                                  );
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Removed from favorites'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
