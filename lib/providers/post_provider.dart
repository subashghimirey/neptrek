import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../utils/constants.dart';
import '../services/cloudinary_service.dart';

class PostProvider with ChangeNotifier {
  List<Post> _posts = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isLoadingAction = false;

  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;
  bool get isLoadingAction => _isLoadingAction;
  String? get errorMessage => _errorMessage;

  final String _postsUrl = '${ApiConstants.apiUrl}/posts/';

  Future<bool> createPost(int trekId, String content, List<File> images, {PostLocation? location, required String token}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // First upload images to Cloudinary if any
      List<String> imageUrls = [];
      if (images.isNotEmpty) {
        imageUrls = await CloudinaryService.uploadImages(images);
      }

      // Create post data
      final post = Post.create(
        trekId: trekId,
        content: content,
        images: imageUrls,

      );

      // Send post request
      final response = await http.post(
        Uri.parse(_postsUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
        body: json.encode(post.toJson()),
      ).timeout(
        const Duration(seconds: 30), // Longer timeout for image upload
        onTimeout: () {
          throw Exception('Request timeout - Server took too long to respond');
        },
      );

      if (response.statusCode == 201) {
        final newPost = Post.fromJson(json.decode(response.body));
        _posts.insert(0, newPost); // Add to beginning of list
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        _errorMessage = errorData['message'] ?? errorData['error'] ?? 'Failed to create post';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      if (e.toString().contains('timeout')) {
        _errorMessage = 'Server is taking too long to respond. Please try again.';
      } else if (e.toString().contains('SocketException')) {
        _errorMessage = 'Cannot connect to server. Please check your internet connection.';
      } else {
        _errorMessage = 'Error creating post: ${e.toString()}';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> likePost(int postId, String token) async {
    _isLoadingAction = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.apiUrl}/posts/$postId/like/'),
        headers: {
          'Authorization': 'Token $token',
        },
      );

      if (response.statusCode == 200) {
        // Update the post's like status in the local list
        final index = _posts.indexWhere((post) => post.id != null && post.id == postId);
        if (index != -1) {
          final post = _posts[index];
          _posts[index] = post.copyWith(
            isLiked: !post.isLiked,
            likesCount: post.isLiked 
              ? post.likesCount - 1 
              : post.likesCount + 1,
          );
          notifyListeners();
        }
        _isLoadingAction = false;
        return true;
      } else {
        _errorMessage = 'Failed to like post';
        _isLoadingAction = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error liking post: ${e.toString()}';
      _isLoadingAction = false;
      notifyListeners();
      return false;
    }
  }

  Future<Comment?> addComment(int postId, String content, String token, {int? parentId}) async {
    _isLoadingAction = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.apiUrl}/comments/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
        body: json.encode({
          'post': postId,
          'content': content,
          'parent': parentId,
        }),
      );

      if (response.statusCode == 201) {
        final newComment = Comment.fromJson(json.decode(response.body));
        
        // Update the post's comments in the local list
        final index = _posts.indexWhere((post) => post.id != null && post.id == postId);
        if (index != -1) {
          final post = _posts[index];
          if (parentId == null) {
            // Add as a new comment
            _posts[index] = post.copyWith(
              comments: [...post.comments, newComment],
              commentsCount: post.commentsCount + 1,
            );
          } else {
            // Add as a reply to an existing comment
            final commentIndex = post.comments.indexWhere((c) => c.id == parentId);
            if (commentIndex != -1) {
              final comment = post.comments[commentIndex];
              final updatedComments = List<Comment>.from(post.comments);
              updatedComments[commentIndex] = comment.copyWith(
                replies: [...comment.replies, newComment],
              );
              _posts[index] = _posts[index].copyWith(
                comments: updatedComments,
                commentsCount: _posts[index].commentsCount + 1,
              );
            }
          }
          notifyListeners();
        }
        
        _isLoadingAction = false;
        return newComment;
      } else {
        _errorMessage = 'Failed to add comment';
        _isLoadingAction = false;
        notifyListeners();
        return null;
      }
    } catch (e) {
      _errorMessage = 'Error adding comment: ${e.toString()}';
      _isLoadingAction = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> fetchPosts(String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(_postsUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Request timeout - Server took too long to respond');
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        _posts = responseData.map((data) => Post.fromJson(data)).toList();
        _isLoading = false;
        notifyListeners();
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        _errorMessage = errorData['message'] ?? errorData['error'] ?? 'Failed to fetch posts';
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      if (e.toString().contains('timeout')) {
        _errorMessage = 'Server is taking too long to respond. Please try again.';
      } else if (e.toString().contains('SocketException')) {
        _errorMessage = 'Cannot connect to server. Please check your internet connection.';
      } else {
        _errorMessage = 'Error fetching posts: ${e.toString()}';
      }
      _isLoading = false;
      notifyListeners();
    }
  }
}
