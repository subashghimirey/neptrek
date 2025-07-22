import 'package:flutter/material.dart';

class PostsScreen extends StatelessWidget {
  const PostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts'),
      ),
      body: const Center(
        child: Text(
          'Posts Coming Soon!',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
