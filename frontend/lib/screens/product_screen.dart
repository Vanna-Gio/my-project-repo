import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../models/product.dart';
import '../providers/category_provider.dart';
import '../providers/product_provider.dart';
import '../services/api_config.dart';

class ProductScreen extends StatefulWidget {
  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  late ProductProvider _productProvider;
  late CategoryProvider _categoryProvider;
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _productProvider = Provider.of<ProductProvider>(context, listen: false);
    _categoryProvider = Provider.of<CategoryProvider>(context, listen: false);

    _productProvider.fetchProducts(reset: true);
    _categoryProvider.fetchCategories('');

    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >=
              _scrollCtrl.position.maxScrollExtent - 200 &&
          !_productProvider.loading &&
          _productProvider.hasMore) {
        _productProvider.fetchProducts();
      }
    });

    _productProvider.addListener(() {
      if (_productProvider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_productProvider.error!),
            backgroundColor: Colors.red,
          ),
        );
      }
      if (_productProvider.message != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_productProvider.message!),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  void _showProductForm({Product? product}) {
    showDialog(
      context: context,
      builder: (_) => ProductFormDialog(
        product: product,
        provider: _productProvider,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showProductForm,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filters
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search products (Khmer / English)',
                  ),
                  onChanged: (value) => _productProvider.onSearch(value),
                ),
                Row(
                  children: [
                    // Sort By
                    Consumer<ProductProvider>(
                      builder: (context, provider, child) =>
                          DropdownButton<String>(
                        value: provider.sortBy,
                        items: const [
                          DropdownMenuItem(
                              value: 'name', child: Text('Sort by Name')),
                          DropdownMenuItem(
                              value: 'price',
                              child: Text('Sort by Price')),
                        ],
                        onChanged: (v) => provider.setSort(v!),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Category Filter
                    Consumer<CategoryProvider>(
                      builder: (context, catProvider, child) {
                        return DropdownButton<int?>(
                          hint: const Text('Category'),
                          value: _productProvider.categoryId,
                          items: [
                            const DropdownMenuItem<int?>(
                              value: null,
                              child: Text('All'),
                            ),
                            ...catProvider.categories.map(
                              (c) => DropdownMenuItem(
                                value: c.id,
                                child: Text(c.name),
                              ),
                            ),
                          ],
                          onChanged: (v) => _productProvider.setCategory(v),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Product List
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (context, provider, child) {
                if (provider.loading && provider.products.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
                  controller: _scrollCtrl,
                  itemCount:
                      provider.products.length + (provider.hasMore ? 1 : 0),
                  itemBuilder: (context, i) {
                    if (i >= provider.products.length) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final p = provider.products[i];
                    final imgUrl = p.imageUrl.isNotEmpty
                        ? '${ApiConfig.imageBaseUrl}/${p.imageUrl}'
                        : null;

                    return ListTile(
                      leading: imgUrl == null
                          ? const Icon(Icons.image_not_supported)
                          : CachedNetworkImage(
                              imageUrl: imgUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.broken_image),
                            ),
                      title: Text(p.name),
                      subtitle: Text('${p.categoryName} • \$${p.price}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showProductForm(product: p),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => provider.deleteProduct(p.id),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ProductFormDialog extends StatefulWidget {
  final Product? product;
  final ProductProvider provider;

  const ProductFormDialog({
    Key? key,
    this.product,
    required this.provider,
  }) : super(key: key);

  @override
  _ProductFormDialogState createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  int? _categoryId;
  XFile? _image;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      final p = widget.product!;
      _nameCtrl.text = p.name;
      _descCtrl.text = p.description;
      _priceCtrl.text = p.price.toString();
      _categoryId =
          Provider.of<CategoryProvider>(context, listen: false)
              .categories
              .firstWhere((c) => c.name == p.categoryName)
              .id;
    }
  }

  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() => _image = image);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image Preview
            if (_image != null)
              Image.file(File(_image!.path), height: 100, fit: BoxFit.cover)
            else if (widget.product?.imageUrl.isNotEmpty == true)
              CachedNetworkImage(
                imageUrl:
                    '${ApiConfig.imageBaseUrl}/${widget.product!.imageUrl}',
                height: 100,
                fit: BoxFit.cover,
              ),
            TextButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text('Pick Image'),
            ),
            // Form Fields
            TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Name')),
            TextField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Description')),
            TextField(
              controller: _priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Price'),
            ),
            Consumer<CategoryProvider>(
              builder: (context, catProvider, child) =>
                  DropdownButtonFormField<int>(
                value: _categoryId,
                hint: const Text('Category'),
                items: catProvider.categories
                    .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                    .toList(),
                onChanged: (v) => setState(() => _categoryId = v),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final name = _nameCtrl.text;
            final desc = _descCtrl.text;
            final price = double.tryParse(_priceCtrl.text) ?? 0.0;

            if (widget.product == null) {
              if (_categoryId != null) {
                widget.provider
                    .createProduct(name, desc, price, _categoryId!, _image);
              }
            } else {
              widget.provider
                  .updateProduct(widget.product!.id, name, desc, price, _image);
            }
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
