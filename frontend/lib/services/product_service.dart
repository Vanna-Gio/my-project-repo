import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../models/product.dart';
import 'api_config.dart';

class ProductService {
  Future<List<Product>> fetchProducts({
    required int page,
    required String search,
    required String sortBy,
    int? categoryId,
  }) async {
    final query = {
      'page': page.toString(),
      'limit': '20',
      'search': search,
      'sort_by': sortBy,
      if (categoryId != null) 'category_id': categoryId.toString(),
    };

    final uri = Uri.parse('${ApiConfig.baseUrl}/products')
        .replace(queryParameters: query);

    final res = await http.get(uri);

    final List data = jsonDecode(res.body);
    return data.map((e) => Product.fromJson(e)).toList();
  }

  Future<String> uploadImage(XFile image) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/upload');
    final req = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('image', image.path));

    final res = await req.send();
    final Map<String, dynamic> data = jsonDecode(await res.stream.bytesToString());
    return data['url'];
  }

  Future<void> createProduct(
    String name,
    String description,
    double price,
    int categoryId,
    XFile? image,
  ) async {
    String imageUrl = '';
    if (image != null) {
      imageUrl = await uploadImage(image);
    }

    await http.post(
      Uri.parse('${ApiConfig.baseUrl}/products'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'description': description,
        'price': price,
        'category_id': categoryId,
        'image_url': imageUrl,
      }),
    );
  }

  Future<void> updateProduct(
    int id,
    String name,
    String description,
    double price,
    XFile? image,
  ) async {
    String imageUrl = '';
    if (image != null) {
      imageUrl = await uploadImage(image);
    }
    
    await http.put(
      Uri.parse('${ApiConfig.baseUrl}/products/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'description': description,
        'price': price,
        'image_url': imageUrl,
      }),
    );
  }

  Future<void> deleteProduct(int id) async {
    await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/products/$id'),
    );
  }
}
