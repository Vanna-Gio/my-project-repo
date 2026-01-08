import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _service = ProductService();

  List<Product> products = [];
  int page = 1;
  bool loading = false;
  bool hasMore = true;
  String? error;
  String? message;

  String search = '';
  String sortBy = 'name';
  int? categoryId;

  Timer? _debounce;

  Future<void> fetchProducts({bool reset = false}) async {
    if (loading) return;

    if (reset) {
      page = 1;
      products.clear();
      hasMore = true;
    }

    loading = true;
    error = null;
    notifyListeners();

    try {
      final newItems = await _service.fetchProducts(
        page: page,
        search: search,
        sortBy: sortBy,
        categoryId: categoryId,
      );
      if (newItems.length < 20) hasMore = false;
      products.addAll(newItems);
      page++;
    } catch (e) {
      error = 'Failed to fetch products: $e';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void onSearch(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      search = value;
      fetchProducts(reset: true);
    });
  }

  void setSort(String value) {
    sortBy = value;
    fetchProducts(reset: true);
  }

  void setCategory(int? id) {
    categoryId = id;
    fetchProducts(reset: true);
  }

  Future<void> createProduct(
    String name,
    String description,
    double price,
    int categoryId,
    XFile? image,
  ) async {
    loading = true;
    error = null;
    message = null;
    notifyListeners();

    try {
      await _service.createProduct(name, description, price, categoryId, image);
      message = 'Product created successfully';
      await fetchProducts(reset: true);
    } catch (e) {
      error = 'Failed to create product: $e';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> updateProduct(
    int id,
    String name,
    String description,
    double price,
    XFile? image,
  ) async {
    loading = true;
    error = null;
    message = null;
    notifyListeners();

    try {
      await _service.updateProduct(id, name, description, price, image);
      message = 'Product updated successfully';
      await fetchProducts(reset: true);
    } catch (e) {
      error = 'Failed to update product: $e';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(int id) async {
    loading = true;
    error = null;
    message = null;
    notifyListeners();

    try {
      await _service.deleteProduct(id);
      products.removeWhere((p) => p.id == id);
      message = 'Product deleted successfully';
    } catch (e) {
      error = 'Failed to delete product: $e';
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
