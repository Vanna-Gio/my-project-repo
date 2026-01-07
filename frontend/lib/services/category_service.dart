import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category.dart';
import 'api_config.dart';

class CategoryService {
  Future<List<Category>> fetchCategories(String search) async {
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/categories?search=$search'),
    );

    final List data = jsonDecode(res.body);
    return data.map((e) => Category.fromJson(e)).toList();
  }

  Future<void> createCategory(String name, String description) async {
    await http.post(
      Uri.parse('${ApiConfig.baseUrl}/categories'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'description': description}),
    );
  }

  Future<void> updateCategory(int id, String name, String description) async {
    await http.put(
      Uri.parse('${ApiConfig.baseUrl}/categories/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'description': description}),
    );
  }

  Future<void> deleteCategory(int id) async {
    await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/categories/$id'),
    );
  }
}
