import 'dart:convert';
import 'package:http/http.dart' as http;
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
}
