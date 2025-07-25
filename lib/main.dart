import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Providers
import 'package:neptrek/providers/auth_provider.dart';
import 'package:neptrek/providers/trek_provider.dart';
import 'package:neptrek/providers/sos_provider.dart';
import 'package:neptrek/providers/tims_provider.dart';
import 'package:neptrek/providers/post_provider.dart';

// Screens
import 'package:neptrek/screens/login_screen.dart';
import 'package:neptrek/screens/home_screen.dart';
import 'package:neptrek/screens/admin_home_screen.dart';
import 'package:neptrek/screens/interests_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => TrekProvider()),
        ChangeNotifierProvider(create: (context) => SOSProvider()),
        ChangeNotifierProvider(create: (context) => TimsProvider()),
        ChangeNotifierProvider(create: (context) => PostProvider()),
      ],
      child: MaterialApp(
        title: 'NepTrek', // Updated app title
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        debugShowCheckedModeBanner: false, 
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            if (authProvider.isLoading) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(), // Loading indicator
                ),
              );
            }
            
            if (!authProvider.isAuthenticated) {
              return const LoginScreen();
            }
            
            // Check if user has set interests, if not show interests screen
            if (!authProvider.hasSetInterests) {
              return const InterestsScreen(isFirstTime: true);
            }
            
            // Direct admin users to admin screen, regular users to home screen
            return authProvider.isAdmin 
              ? const AdminHomeScreen() 
              : const HomeScreen();
          },
        ),
      ),
    );
  }
}