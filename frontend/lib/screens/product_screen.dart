import 'dart:async';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../services/product_service.dart';
import '../services/category_service.dart';
import '../services/api_config.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductScreen extends StatefulWidget {
  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final ProductService productService = ProductService();
  final CategoryService categoryService = CategoryService();

  List<Product> products = [];
  List<Category> categories = [];

  int page = 1;
  bool loading = false;
  bool hasMore = true;

  String search = '';
  String sortBy = 'name';
  int? selectedCategoryId;

  final searchCtrl = TextEditingController();
  Timer? debounce;
  final ScrollController scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    loadCategories();
    loadProducts(reset: true);

    scrollCtrl.addListener(() {
      if (scrollCtrl.position.pixels >=
              scrollCtrl.position.maxScrollExtent - 100 &&
          !loading &&
          hasMore) {
        loadProducts();
      }
    });
  }

  Future<void> loadCategories() async {
    categories = await categoryService.fetchCategories('');
    setState(() {});
  }

  Future<void> loadProducts({bool reset = false}) async {
    if (loading) return;

    if (reset) {
      page = 1;
      products.clear();
      hasMore = true;
    }

    setState(() => loading = true);

    final newItems = await productService.fetchProducts(
      page: page,
      search: search,
      sortBy: sortBy,
      categoryId: selectedCategoryId,
    );

    if (newItems.length < 20) hasMore = false;

    products.addAll(newItems);
    page++;

    setState(() => loading = false);
  }

  void onSearchChanged(String value) {
    if (debounce?.isActive ?? false) debounce!.cancel();
    debounce = Timer(const Duration(milliseconds: 500), () {
      search = value;
      loadProducts(reset: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: searchCtrl,
              decoration: const InputDecoration(
                hintText: 'Search products (Khmer / English)',
              ),
              onChanged: onSearchChanged,
            ),
          ),

          // Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                DropdownButton<String>(
                  value: sortBy,
                  items: const [
                    DropdownMenuItem(value: 'name', child: Text('Sort by Name')),
                    DropdownMenuItem(value: 'price', child: Text('Sort by Price')),
                  ],
                  onChanged: (v) {
                    sortBy = v!;
                    loadProducts(reset: true);
                  },
                ),
                const SizedBox(width: 16),
                DropdownButton<int?>(
                  value: selectedCategoryId,
                  hint: const Text('Category'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All')),
                    ...categories.map(
                      (c) => DropdownMenuItem(
                        value: c.id,
                        child: Text(c.name),
                      ),
                    ),
                  ],
                  onChanged: (v) {
                    selectedCategoryId = v;
                    loadProducts(reset: true);
                  },
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              controller: scrollCtrl,
              itemCount: products.length + (loading ? 1 : 0),
              itemBuilder: (_, i) {
                if (i >= products.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final p = products[i];
                final imgUrl = p.imageUrl.isNotEmpty
                    ? '${ApiConfig.imageBaseUrl}${p.imageUrl}'
                    : null;

                return ListTile(
                  leading: imgUrl == null
                      ? const Icon(Icons.image_not_supported)
                      : CachedNetworkImage(
                          imageUrl: imgUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              const CircularProgressIndicator(),
                          errorWidget: (_, __, ___) =>
                              const Icon(Icons.broken_image),
                        ),
                  title: Text(p.name),
                  subtitle: Text('${p.categoryName} • \$${p.price}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
