import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sos_provider.dart';
import '../providers/auth_provider.dart';

class SOSScreen extends StatefulWidget {
  const SOSScreen({super.key});

  @override
  State<SOSScreen> createState() => _SOSScreenState();
}

class _SOSScreenState extends State<SOSScreen> {
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Fetch SOS alerts when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.token != null) {
        Provider.of<SOSProvider>(context, listen: false)
            .fetchSOSAlerts(authProvider.token!);
      }
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _sendSOSAlert() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to send SOS alert')),
      );
      return;
    }

    final sosProvider = Provider.of<SOSProvider>(context, listen: false);
    final success = await sosProvider.sendSOSAlert(
      _descriptionController.text,
      authProvider.token!,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('SOS alert sent successfully')),
      );
      _descriptionController.clear();
      // Refresh the list of SOS alerts
      sosProvider.fetchSOSAlerts(authProvider.token!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(sosProvider.errorMessage ?? 'Failed to send SOS alert')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('SOS'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Send Alert'),
              Tab(text: 'My Alerts'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Send Alert Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Send SOS Alert',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Describe your emergency situation',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Consumer<SOSProvider>(
                      builder: (context, sosProvider, child) {
                        return ElevatedButton(
                          onPressed: sosProvider.isLoading ? null : _sendSOSAlert,
                          child: sosProvider.isLoading
                              ? const CircularProgressIndicator()
                              : const Text('SEND SOS ALERT'),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            // My Alerts Tab
            Consumer<SOSProvider>(
              builder: (context, sosProvider, child) {
                if (sosProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (sosProvider.errorMessage != null) {
                  return Center(child: Text(sosProvider.errorMessage!));
                }

                if (sosProvider.sosAlerts.isEmpty) {
                  return const Center(child: Text('No SOS alerts found'));
                }

                return ListView.builder(
                  itemCount: sosProvider.sosAlerts.length,
                  itemBuilder: (context, index) {
                    final alert = sosProvider.sosAlerts[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        title: Text(alert['description']),
                        subtitle: Text(
                          'Location: ${alert['latitude']}, ${alert['longitude']}\n'
                          'Date: ${DateTime.parse(alert['created_at']).toLocal()}',
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
