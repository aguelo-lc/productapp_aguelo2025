import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'product_detail_page.dart';

class CategoryProductsScreen extends StatefulWidget {
  final Map<String, dynamic> initialCategory;
  final List<dynamic> allCategories;

  const CategoryProductsScreen({
    required this.initialCategory,
    required this.allCategories,
    super.key,
  });

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  late Map<String, dynamic> selectedCategory;
  List<dynamic> products = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.initialCategory;
    fetchProductsByCategory();
  }

  Future<void> fetchProductsByCategory() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final response = await http.get(
        Uri.parse(
          '${AppConfig.baseUrl}/api/categories/${selectedCategory['id']}/products',
        ),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          products = data['data'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load products.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Connection error.';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(selectedCategory['name'] ?? 'Category')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: DropdownButton<Map<String, dynamic>>(
              value: selectedCategory,
              isExpanded: true,
              items:
                  widget.allCategories
                      .map<DropdownMenuItem<Map<String, dynamic>>>((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Text(cat['name'] ?? ''),
                        );
                      })
                      .toList(),
              onChanged: (cat) {
                if (cat != null) {
                  setState(() {
                    selectedCategory = cat;
                  });
                  fetchProductsByCategory();
                }
              },
            ),
          ),
          Expanded(
            child:
                isLoading
                    ? Center(child: CircularProgressIndicator())
                    : errorMessage != null
                    ? Center(child: Text(errorMessage!))
                    : products.isEmpty
                    ? Center(child: Text('No products found.'))
                    : ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final item = products[index];
                        return ListTile(
                          leading:
                              (item['image_path'] != null &&
                                      item['image_path'].toString().isNotEmpty)
                                  ? Image.network(
                                    '${AppConfig.baseUrl}/storage/${item['image_path']}',
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Icon(Icons.broken_image),
                                  )
                                  : Image.asset(
                                    'assets/images/product_placeholder.png',
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                          title: Text(item['name'] ?? ''),
                          subtitle: Text('₱${item['price']}'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ProductDetailPage(
                                      name: item['name'] ?? '',
                                      price: '₱${item['price']}',
                                      image:
                                          (item['image_path'] != null &&
                                                  item['image_path']
                                                      .toString()
                                                      .isNotEmpty)
                                              ? '${AppConfig.baseUrl}/storage/${item['image_path']}'
                                              : 'assets/images/product_placeholder.png',
                                      rating: 5,
                                      description: item['description'] ?? '',
                                      category: selectedCategory,
                                      allCategories: widget.allCategories,
                                    ),
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
