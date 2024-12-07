import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CloudinaryService {
  final String cloudName = 'your-cloud-name';
  final String apiKey = 'your-api-key';
  final String apiSecret = 'your-api-secret';

  Future<String?> uploadImage(File image) async {
    final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload');
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = 'your-upload-preset'
      ..fields['api_key'] = apiKey
      ..files.add(await http.MultipartFile.fromPath('file', image.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseBody);
      return jsonResponse['secure_url'];
    } else {
      print('Failed to upload image: ${response.reasonPhrase}');
      return null;
    }
  }

  
}
