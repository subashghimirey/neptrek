import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String cloudName = 'dq8k8enle';
  static const String uploadPreset = 'posts_images';
  static const String apiKey = '512219932247324';

  static String get uploadUrl => 
    'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

  static Future<String?> uploadImage(File image) async {
    try {
      final uri = Uri.parse(uploadUrl);
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..fields['api_key'] = apiKey
        ..files.add(
          await http.MultipartFile.fromPath(
            'file',
            image.path,
          ),
        );

      final response = await request.send();
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      final jsonData = json.decode(responseString);

      if (response.statusCode == 200) {
        return jsonData['secure_url'];
      } else {
        throw Exception('Failed to upload image: ${jsonData['error']['message']}');
      }
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }

  static Future<List<String>> uploadImages(List<File> images) async {
    final List<String> uploadedUrls = [];
    
    for (final image in images) {
      final url = await uploadImage(image);
      if (url != null) {
        uploadedUrls.add(url);
      }
    }
    
    return uploadedUrls;
  }
}
