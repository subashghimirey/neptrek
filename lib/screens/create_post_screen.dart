import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../providers/post_provider.dart';
import '../providers/trek_provider.dart';
import '../providers/auth_provider.dart';
import '../models/trek_model.dart';
import '../models/post_model.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  Trek? _selectedTrek;
  final List<File> _selectedImages = [];
  String _content = '';
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _selectedImages.add(File(image.path));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedTrek == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final success = await Provider.of<PostProvider>(context, listen: false)
          .createPost(_selectedTrek!.id, _content, _selectedImages, token: token);

      if (success) {
        Navigator.of(context).pop(true); // Pass true to indicate success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Provider.of<PostProvider>(context, listen: false).errorMessage ?? 
              'Failed to create post'
            ),
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final treks = Provider.of<TrekProvider>(context).treks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Trek Dropdown
            DropdownButtonFormField<Trek>(
              value: _selectedTrek,
              decoration: const InputDecoration(
                labelText: 'Select Trek *',
                border: OutlineInputBorder(),
              ),
              items: treks.map((trek) {
                return DropdownMenuItem(
                  value: trek,
                  child: Text(trek.name),
                );
              }).toList(),
              onChanged: (Trek? value) {
                setState(() {
                  _selectedTrek = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a trek';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Content Text Field
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Content *',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              onChanged: (value) => _content = value,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some content';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Selected Images
            if (_selectedImages.isNotEmpty) ...[
              const Text('Selected Images:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          Image.file(_selectedImages[index], height: 100, width: 100, fit: BoxFit.cover),
                          Positioned(
                            right: 0,
                            child: IconButton(
                              icon: const Icon(Icons.remove_circle, color: Colors.red),
                              onPressed: () => _removeImage(index),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Add Image Button
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Add Image'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Create Post'),
            ),
          ],
        ),
      ),
    );
  }
}
