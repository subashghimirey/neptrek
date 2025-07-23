// lib/screens/trek_details_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:neptrek/providers/trek_provider.dart';
import 'package:neptrek/models/trek_model.dart';
import 'package:neptrek/providers/auth_provider.dart';
import 'package:neptrek/screens/tims_booking_screen.dart';
import 'package:neptrek/utils/asset_constants.dart';

class TrekDetailsScreen extends StatefulWidget {
  final int trekId;
  final String? trekName; // Optional, for display in app bar while loading

  const TrekDetailsScreen({
    super.key,
    required this.trekId,
    this.trekName,
  });

  @override
  State<TrekDetailsScreen> createState() => _TrekDetailsScreenState();
}

class _TrekDetailsScreenState extends State<TrekDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch trek details when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final trekProvider = Provider.of<TrekProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      trekProvider.fetchTrekDetails(widget.trekId);
      
      // Fetch favorites to ensure we have the latest state
      if (authProvider.token != null) {
        trekProvider.fetchFavorites(authProvider.token);
      }
    });
  }

  void _toggleFavorite() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final trekProvider = Provider.of<TrekProvider>(context, listen: false);
    
    if (authProvider.user?.user.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to add to favorites'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    final isFav = trekProvider.isFavorite(widget.trekId.toString());
    trekProvider.toggleFavorite(
      widget.trekId.toString(),
      authProvider.token,
      userId: authProvider.user!.user.id.toString(),
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isFav ? 'Removed from favorites' : 'Added to favorites!'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<TrekProvider>(
        builder: (context, trekProvider, child) {
          return CustomScrollView(
            slivers: [
              // Custom app bar with image
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      trekProvider.isFavorite(widget.trekId.toString())
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: trekProvider.isFavorite(widget.trekId.toString())
                          ? Colors.red
                          : Colors.white,
                      size: 28,
                    ),
                    onPressed: _toggleFavorite,
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: trekProvider.selectedTrek?.photos.isNotEmpty == true
                    ? Image.network(
                        trekProvider.selectedTrek!.photos[0],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Image.asset(
                          AssetConstants.defaultTrekImage,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Image.asset(
                        AssetConstants.defaultTrekImage,
                        fit: BoxFit.cover,
                      ),
                  title: Text(
                    trekProvider.selectedTrek?.name ?? widget.trekName ?? 'Trek Details',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 1),
                          blurRadius: 4,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Content
              SliverToBoxAdapter(
                child: _buildContent(trekProvider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(TrekProvider trekProvider) {
    if (trekProvider.isLoadingDetails) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (trekProvider.detailsErrorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
                          trekProvider.detailsErrorMessage!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      trekProvider.fetchTrekDetails(widget.trekId);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final trek = trekProvider.selectedTrek;
    if (trek == null) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(
          child: Text(
            'No trek details available',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // TIMS Pass Booking Button
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.green.shade100),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.verified_user,
                            color: Colors.green.shade700,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'TIMS Pass Required',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade100),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.green, size: 20),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'TIMS (Trekkers\' Information Management System) is mandatory for trekking',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.green,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.confirmation_number, size: 20),
                        label: const Text(
                          'Book TIMS Pass',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          final authProvider = Provider.of<AuthProvider>(context, listen: false);
                          if (!authProvider.isAuthenticated) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please log in to book TIMS pass'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            return;
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TimsBookingScreen(
                                trekId: trek.id,
                                trekkerArea: trek.region,
                                route: '${trek.name} Trek',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Basic Info Section
            _buildBasicInfoSection(trek),
            const SizedBox(height: 24),
            
            // Description Section
            _buildDescriptionSection(trek),
            const SizedBox(height: 24),
            
            // Itinerary Section
            _buildItinerarySection(trek),
            const SizedBox(height: 24),
            
            // Cost Breakdown Section
            _buildCostSection(trek),
            const SizedBox(height: 24),
            
            // Elevation Profile Section
            _buildElevationSection(trek),
            const SizedBox(height: 24),
            
            // Permits Section
            _buildPermitsSection(trek),
            const SizedBox(height: 24),
            
            // Recommended Gear Section
            _buildGearSection(trek),
            const SizedBox(height: 24),
            
            // Safety Info Section
            if (trek.safetyInfo.altitudeSicknessRisk?.isNotEmpty == true) ...[
              _buildSafetySection(trek),
              const SizedBox(height: 24),
            ],
            
            // Photos Gallery Section
            if (trek.photos.isNotEmpty) ...[
              _buildPhotosSection(trek),
              const SizedBox(height: 24),
            ],
            
            // Nearby Attractions Section
            if (trek.nearbyAttractions.isNotEmpty) ...[
              _buildAttractionsSection(trek),
              const SizedBox(height: 32),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection(Trek trek) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overview',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Region', trek.region, Icons.location_on),
            _buildInfoRow('District', trek.district, Icons.map),
            _buildInfoRow('Difficulty', trek.difficulty, Icons.trending_up),
            _buildInfoRow('Duration', trek.duration, Icons.schedule),
            _buildInfoRow('Best Seasons', trek.bestSeasons.join(', '), Icons.wb_sunny),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionSection(Trek trek) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              trek.description,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            if (trek.historicalSignificance?.isNotEmpty == true) ...[
              const SizedBox(height: 16),
              const Text(
                'Historical Significance',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                trek.historicalSignificance!,
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildItinerarySection(Trek trek) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Itinerary',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...trek.itinerary.map((day) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 6, right: 12),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      day,
                      style: const TextStyle(fontSize: 14, height: 1.4),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCostSection(Trek trek) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cost Breakdown',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildCostRow('Permits', trek.costBreakdown.permits),
            _buildCostRow('Guide', trek.costBreakdown.guide),
            _buildCostRow('Porter', trek.costBreakdown.porter),
            _buildCostRow('Accommodation', trek.costBreakdown.accommodation),
            _buildCostRow('Food', trek.costBreakdown.food),
            const SizedBox(height: 12),
            const Text(
              'Transportation',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              trek.transportation,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildElevationSection(Trek trek) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Elevation Profile',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Max Elevation', trek.elevationProfile.maxElevation, Icons.keyboard_arrow_up),
            _buildInfoRow('Min Elevation', trek.elevationProfile.minElevation, Icons.keyboard_arrow_down),
          ],
        ),
      ),
    );
  }

  Widget _buildPermitsSection(Trek trek) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Required Permits',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...trek.requiredPermits.map((permit) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Icon(Icons.verified, color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      permit,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildGearSection(Trek trek) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recommended Gear',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: trek.recommendedGear.map((gear) => Chip(
                label: Text(
                  gear,
                  style: const TextStyle(fontSize: 12),
                ),
                backgroundColor: Colors.blue.shade50,
                side: BorderSide(color: Colors.blue.shade200),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetySection(Trek trek) {
    if (trek.safetyInfo.altitudeSicknessRisk?.isEmpty != false) return const SizedBox.shrink();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Safety Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange.shade600),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Altitude Sickness Risk',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          trek.safetyInfo.altitudeSicknessRisk!,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotosSection(Trek trek) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Photo Gallery',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: trek.photos.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 160,
                    margin: const EdgeInsets.only(right: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        trek.photos[index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade300,
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttractionsSection(Trek trek) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nearby Attractions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...trek.nearbyAttractions.map((attraction) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Icon(Icons.place, color: Colors.blue, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    attraction,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
