import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tims_provider.dart';
import '../providers/auth_provider.dart';
import '../models/tims_model.dart';

class TimsListScreen extends StatefulWidget {
  const TimsListScreen({super.key});

  @override
  State<TimsListScreen> createState() => _TimsListScreenState();
}

class _TimsListScreenState extends State<TimsListScreen> {
  bool _isInit = false;
  
  @override
  void didChangeDependencies() {
    if (!_isInit) {
      _fetchTimsBookings();
      _isInit = true;
    }
    super.didChangeDependencies();
  }

  Future<void> _fetchTimsBookings() async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token != null) {
      await Provider.of<TimsProvider>(context, listen: false).fetchUserBookings(token);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My TIMS Bookings'),
      ),
      body: Consumer<TimsProvider>(
        builder: (ctx, timsProvider, child) {
          if (timsProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (timsProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(timsProvider.errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchTimsBookings,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final bookings = timsProvider.bookings;
          if (bookings.isEmpty) {
            return const Center(
              child: Text('No TIMS bookings found'),
            );
          }

          return RefreshIndicator(
            onRefresh: _fetchTimsBookings,
            child: ListView.builder(
              itemCount: bookings.length,
              itemBuilder: (ctx, i) {
                final booking = bookings[i];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(booking.image),
                    ),
                    title: Text(booking.fullName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Trek: ${booking.trekkerArea} - ${booking.route}'),
                        Text('Dates: ${booking.entryDate} to ${booking.exitDate}'),
                        Text('Payment Status: ${booking.paymentStatus ?? "pending"}'),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Rs. ${booking.permitCost}'),
                        Text('ID: ${booking.transactionId}'),
                      ],
                    ),
                    isThreeLine: true,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(booking.fullName),
                          content: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Nationality: ${booking.nationality}'),
                                Text('Passport: ${booking.passportNumber}'),
                                Text('Gender: ${booking.gender}'),
                                Text('Date of Birth: ${booking.dateOfBirth}'),
                                const Divider(),
                                Text('Trek Area: ${booking.trekkerArea}'),
                                Text('Route: ${booking.route}'),
                                Text('Entry Date: ${booking.entryDate}'),
                                Text('Exit Date: ${booking.exitDate}'),
                                const Divider(),
                                Text('Nepal Contact: ${booking.nepalContactName}'),
                                Text('Organization: ${booking.nepalOrganization}'),
                                Text('Designation: ${booking.nepalDesignation}'),
                                Text('Nepal Mobile: ${booking.nepalMobile}'),
                                Text('Nepal Office: ${booking.nepalOfficeNumber}'),
                                Text('Nepal Address: ${booking.nepalAddress}'),
                                const Divider(),
                                Text('Home Contact: ${booking.homeContactName}'),
                                Text('Home City: ${booking.homeCity}'),
                                Text('Home Mobile: ${booking.homeMobile}'),
                                Text('Home Office: ${booking.homeOfficeNumber}'),
                                Text('Home Address: ${booking.homeAddress}'),
                                const Divider(),
                                Text('Transit Pass Cost: Rs. ${booking.transitPassCost}'),
                                Text('Permit Cost: Rs. ${booking.permitCost}'),
                                Text('Payment Status: ${booking.paymentStatus ?? "pending"}'),
                                Text('Transaction ID: ${booking.transactionId}'),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
