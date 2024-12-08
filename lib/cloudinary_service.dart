import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CloudinaryService {
  final String cloudName = 'dtgra3zko';
  final String apiKey = '116657193166624';
  final String apiSecret = 'NEWhCIIzZRGvm5j5zTCN8cCeEn8';

  Future<String?> uploadImage(File image) async {
    final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload');
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = 'ml_default'
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
