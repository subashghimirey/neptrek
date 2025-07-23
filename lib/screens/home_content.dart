import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:neptrek/providers/auth_provider.dart';
import 'package:neptrek/providers/trek_provider.dart';
import 'package:neptrek/models/trek_model.dart';
import 'package:neptrek/screens/trek_details_screen.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final trekProvider = Provider.of<TrekProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('NepTrek'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            _buildWelcomeSection(authProvider),
            const SizedBox(height: 24),
            _buildTreksSection(context, trekProvider),
            const SizedBox(height: 32),
            _buildRecommendedSection(context, trekProvider, authProvider),
          ],
        ),
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

  Widget _buildTreksSection(BuildContext context, TrekProvider trekProvider) {
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
                return _buildTrekCard(context, trek);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildRecommendedSection(BuildContext context, TrekProvider trekProvider, AuthProvider authProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                authProvider.isAuthenticated && authProvider.hasSetInterests
                    ? 'Recommended for You'
                    : 'Featured Treks',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (trekProvider.isLoadingRecommended)
              const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
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
              overflow: TextOverflow.ellipsis,
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
                    overflow: TextOverflow.ellipsis,
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
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
        else
          SizedBox(
            height: 300,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: trekProvider.recommendedTreks.length,
              itemBuilder: (context, index) {
                final trek = trekProvider.recommendedTreks[index];
                return _buildTrekCard(context, trek, isRecommended: true);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildTrekCard(BuildContext context, Trek trek, {bool isRecommended = false}) {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Material(
          color: Colors.white,
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
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                  ),
                  child: trek.photos.isNotEmpty
                      ? Image.network(
                          trek.photos.first,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade300,
                              child: const Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                                size: 40,
                              ),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey.shade300,
                          child: const Icon(
                            Icons.landscape,
                            color: Colors.grey,
                            size: 40,
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
                        // Recommended badge
                        if (isRecommended)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'RECOMMENDED',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ),
                        if (isRecommended) const SizedBox(height: 6),
                        // Trek name
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
                        // Region and difficulty
                        Text(
                          '${trek.region} • ${trek.difficulty}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Duration
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
                        const SizedBox(height: 6),
                        // Max elevation
                        if (trek.elevationProfile.maxElevation.isNotEmpty)
                          Row(
                            children: [
                              Icon(
                                Icons.terrain,
                                size: 14,
                                color: Colors.blue.shade600,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  trek.elevationProfile.maxElevation,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.blue.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
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
      ),
    );
  }
}
