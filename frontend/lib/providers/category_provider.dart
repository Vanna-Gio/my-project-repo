import 'dart:async';
import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/category_service.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryService _service = CategoryService();

  List<Category> categories = [];
  bool loading = false;
  String? error;
  String? message;

  Timer? _debounce;

  Future<void> fetchCategories(String search) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      categories = await _service.fetchCategories(search);
    } catch (e) {
      error = 'Failed to fetch categories: $e';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void onSearch(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      fetchCategories(value);
    });
  }

  Future<void> createCategory(String name, String description) async {
    loading = true;
    error = null;
    message = null;
    notifyListeners();

    try {
      await _service.createCategory(name, description);
      message = 'Category created successfully';
      await fetchCategories('');
    } catch (e) {
      error = 'Failed to create category: $e';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> updateCategory(int id, String name, String description) async {
    loading = true;
    error = null;
    message = null;
    notifyListeners();

    try {
      await _service.updateCategory(id, name, description);
      message = 'Category updated successfully';
      final index = categories.indexWhere((c) => c.id == id);
      if (index != -1) {
        categories[index] = Category(
          id: id,
          name: name,
          description: description,
        );
      }
    } catch (e) {
      error = 'Failed to update category: $e';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> deleteCategory(int id) async {
    loading = true;
    error = null;
    message = null;
    notifyListeners();

    try {
      await _service.deleteCategory(id);
      message = 'Category deleted successfully';
      categories.removeWhere((c) => c.id == id);
    } catch (e) {
      error = 'Failed to delete category: $e';
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
