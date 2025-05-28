import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'edit_product_screen.dart';

class MyProductsScreen extends StatefulWidget {
  const MyProductsScreen({super.key});

  @override
  _MyProductsScreenState createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> {
  // List of user's products and loading state
  List<dynamic> myProducts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMyProducts(); // Fetch user's products on load
  }

  // Fetches products belonging to the current user
  Future<void> fetchMyProducts() async {
    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    if (userId == null) return;
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/api/products/$userId'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Defensive: handle both single product and list
      List<dynamic> products;
      if (data is Map<String, dynamic> && data.containsKey('data')) {
        products = data['data'] ?? [];
      } else if (data is Map<String, dynamic> && data.containsKey('id')) {
        products = [data];
      } else if (data is List) {
        products = data;
      } else {
        products = [];
      }
      setState(() {
        myProducts = products;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  // Deletes a product by ID and updates the list
  Future<void> deleteProduct(int productId) async {
    final response = await http.delete(
      Uri.parse('${AppConfig.baseUrl}/api/products/$productId'),
    );
    if (response.statusCode == 200) {
      setState(() {
        myProducts.removeWhere((item) => item['id'] == productId);
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Product deleted')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Products')),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator()) // Show loading
              : ListView.builder(
                itemCount: myProducts.length,
                itemBuilder: (context, index) {
                  final item = myProducts[index];
                  return ListTile(
                    leading: SizedBox(
                      width: 60,
                      height: 60,
                      child:
                          (item['image_path'] != null &&
                                  item['image_path'].toString().isNotEmpty)
                              ? Image.network(
                                '${AppConfig.baseUrl}/storage/${item['image_path']}',
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) => Image.asset(
                                      'assets/images/product_placeholder.png',
                                      fit: BoxFit.cover,
                                    ),
                              )
                              : Image.asset(
                                'assets/images/product_placeholder.png',
                                fit: BoxFit.cover,
                              ),
                    ),
                    title: Text(item['name'] ?? ''),
                    subtitle: Text(item['description'] ?? ''),
                    trailing: IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => EditProductScreen(product: item),
                          ),
                        ).then((_) => fetchMyProducts()); // Refresh after edit
                      },
                    ),
                    // Long press to delete with confirmation dialog
                    onLongPress: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: Text('Delete Product'),
                              content: Text(
                                'Are you sure you want to delete this product?',
                              ),
                              actions: [
                                TextButton(
                                  child: Text('Cancel'),
                                  onPressed:
                                      () => Navigator.pop(context, false),
                                ),
                                TextButton(
                                  child: Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  onPressed: () => Navigator.pop(context, true),
                                ),
                              ],
                            ),
                      );
                      if (confirm == true) {
                        await deleteProduct(item['id']);
                      }
                    },
                  );
                },
              ),
    );
  }
}
