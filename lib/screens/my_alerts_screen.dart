import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:neptrek/models/sos_model.dart';
import 'package:neptrek/screens/alert_details_screen.dart';
import 'package:neptrek/services/sos_service.dart';
import 'package:neptrek/providers/auth_provider.dart';

class MyAlertsScreen extends StatefulWidget {
  const MyAlertsScreen({super.key});

  @override
  State<MyAlertsScreen> createState() => _MyAlertsScreenState();
}


class _MyAlertsScreenState extends State<MyAlertsScreen> {
  late Future<List<SOSAlert>> _alertsFuture;

  @override
  void initState() {
    super.initState();
    _alertsFuture = SOSService.getMyAlerts(authToken: Provider.of<AuthProvider>(context, listen: false).token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Alerts'),
        elevation: 0,
      ),
      body: FutureBuilder<List<SOSAlert>>(
        future: _alertsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final List<SOSAlert> alerts = snapshot.data ?? [];
          if (alerts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No alerts yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your emergency alerts will appear here',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          } else {
            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: alerts.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final alert = alerts[index];
                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: alert.isResolved ? Colors.green[50] : Colors.red[50],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      alert.isResolved ? Icons.check_circle : Icons.warning,
                      color: alert.isResolved ? Colors.green : Colors.red,
                    ),
                  ),
                  title: Text(alert.alertType),
                  subtitle: Text(
                    alert.location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AlertDetailsScreen(alertId: int.parse(alert.id)),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
