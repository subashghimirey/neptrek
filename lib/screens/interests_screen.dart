// lib/screens/interests_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:neptrek/providers/auth_provider.dart';

class InterestsScreen extends StatefulWidget {
  final bool isFirstTime; // Whether this is the first time setting interests
  
  const InterestsScreen({
    super.key,
    this.isFirstTime = false,
  });

  @override
  State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> {
  // Available interests - you can expand this list or fetch from API
  static const List<String> availableInterests = [
    'Adventure Trekking',
    'High Altitude Climbing',
    'Cultural Immersion',
    'Photography',
    'Wildlife & Nature',
    'Spiritual Journey',
    'Mountain Peaks',
    'Historical Sites',
    'Tea House Trekking',
    'Camping',
    'Rock Climbing',
    'Mountaineering',
    'Local Cuisine',
    'Traditional Villages',
    'Buddhist Monasteries',
    'Himalayan Views',
    'Glacier Exploration',
    'Alpine Lakes',
    'Base Camp Treks',
    'Circuit Treks',
    'Off-the-beaten-path',
    'Group Trekking',
    'Solo Adventure',
    'Family Friendly',
    'Moderate Difficulty',
    'Challenging Treks',
    'Multi-day Expeditions',
    'Day Hikes',
  ];

  late Set<String> selectedInterests;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize with current user interests
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    selectedInterests = Set<String>.from(authProvider.user?.interests ?? []);
  }

  Future<void> _saveInterests() async {
    if (selectedInterests.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one interest'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.updateUserInterests(selectedInterests.toList());

    if (!mounted) return; // Check if widget is still mounted before updating state

    setState(() {
      isLoading = false;
    });

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Interests updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      if (widget.isFirstTime) {
        // Navigate to home screen if this is first time setup
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      } else {
        // Just go back if updating interests
        Navigator.of(context).pop();
      }
    } else {
      final errorMessage = authProvider.errorMessage ?? 'Failed to update interests';
      
      // Check if it's an authentication error
      if (errorMessage.contains('session has expired') || errorMessage.contains('login again')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );
        
        // Navigate to login screen since session expired
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isFirstTime ? 'Welcome! Tell us your interests' : 'Update Your Interests'),
        automaticallyImplyLeading: !widget.isFirstTime, // No back button on first time
      ),
      body: Column(
        children: [
          // Header section
          Container(
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
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isFirstTime 
                    ? 'What interests you most about trekking in Nepal?'
                    : 'Update your trekking interests',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.isFirstTime
                    ? 'Select your interests to get personalized trek recommendations.'
                    : 'Your interests help us recommend the best treks for you.',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          
          // Interests selection
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Select your interests:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${selectedInterests.length} selected',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Interests chips
                  Expanded(
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: availableInterests.map((interest) {
                          final isSelected = selectedInterests.contains(interest);
                          return FilterChip(
                            label: Text(
                              interest,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black87,
                                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  selectedInterests.add(interest);
                                } else {
                                  selectedInterests.remove(interest);
                                }
                              });
                            },
                            backgroundColor: Colors.grey.shade200,
                            selectedColor: Colors.blue.shade500,
                            checkmarkColor: Colors.white,
                            elevation: isSelected ? 4 : 1,
                            pressElevation: 2,
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom action buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                if (selectedInterests.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade600, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'You\'ve selected ${selectedInterests.length} interest${selectedInterests.length == 1 ? '' : 's'}. This will help us recommend the perfect treks for you!',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                Row(
                  children: [
                    if (!widget.isFirstTime)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isLoading ? null : () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancel'),
                        ),
                      ),
                    if (!widget.isFirstTime) const SizedBox(width: 12),
                    Expanded(
                      flex: widget.isFirstTime ? 1 : 2,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _saveInterests,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                widget.isFirstTime ? 'Get Started' : 'Update Interests',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
