import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/post_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/post_card.dart';
import './create_post_screen.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    if (!_isInit) {
      _fetchPosts();
      _isInit = true;
    }
    super.didChangeDependencies();
  }

  Future<void> _fetchPosts() async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token != null) {
      await Provider.of<PostProvider>(context, listen: false).fetchPosts(token);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => const CreatePostScreen(),
            ),
          ).then((_) => _fetchPosts()); // Refresh posts after creating new one
        },
        child: const Icon(Icons.add),
      ),
      body: Consumer<PostProvider>(
        builder: (ctx, postProvider, child) {
          if (postProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (postProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(postProvider.errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchPosts,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final posts = postProvider.posts;
          if (posts.isEmpty) {
            return const Center(
              child: Text('No posts yet. Be the first to share!'),
            );
          }

          return RefreshIndicator(
            onRefresh: () => _fetchPosts(),
            child: ListView.builder(
              itemCount: posts.length,
              itemBuilder: (ctx, i) {
                final post = posts[i];
                return PostCard(
                  key: ValueKey(post.id),
                  post: post,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
