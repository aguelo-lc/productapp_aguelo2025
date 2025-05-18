import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/theme_model.dart'; // Adjust the import path
import 'category_products_screen.dart'; // Adjust the import path

class ProductDetailPage extends StatelessWidget {
  final String name;
  final String price;
  final String image;
  final int rating;
  final String description;
  final Map<String, dynamic>? category;
  final List<dynamic>? allCategories;

  const ProductDetailPage({
    super.key,
    required this.name,
    required this.price,
    required this.image,
    required this.rating,
    required this.description,
    this.category,
    this.allCategories,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
      builder: (context, theme, child) {
        return Scaffold(
          backgroundColor: theme.scaffoldColor,
          appBar: AppBar(
            title: const Text("Shop It!"),
            backgroundColor: theme.appBarColor,
            actions: [
              CircleAvatar(
                backgroundColor: theme.buttonColor,
                child: const Text("A", style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 12),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                image.startsWith('http')
                    ? Image.network(image)
                    : Image.asset(image),
                const SizedBox(height: 12),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.textColor,
                  ),
                ),
                Text(
                  price,
                  style: const TextStyle(fontSize: 18, color: Colors.red),
                ),
                // Category section
                if (category != null &&
                    (category!['name']?.toString().isNotEmpty ?? false))
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        if (allCategories != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => CategoryProductsScreen(
                                    initialCategory: category!,
                                    allCategories: allCategories!,
                                  ),
                            ),
                          );
                        }
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Category:',
                            style: TextStyle(
                              color: theme.textColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.category,
                            color: theme.buttonColor,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            category!['name'],
                            style: TextStyle(
                              color: theme.buttonColor,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      Icons.star,
                      color:
                          index < rating ? theme.starColor : Colors.grey[300],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.buttonColor,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.shop_2),
                  label: const Text("Buy Product"),
                ),
                const SizedBox(height: 12),
                Text(
                  "Description",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.textColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(description, style: TextStyle(color: theme.textColor)),
                const Divider(height: 30),
                ListTile(
                  leading: Icon(Icons.store, color: theme.textColor),
                  title: Text(
                    "NC General Merchandise",
                    style: TextStyle(color: theme.textColor),
                  ),
                  subtitle: Text(
                    "Cagayan de Oro City",
                    style: TextStyle(color: theme.textColor.withOpacity(0.7)),
                  ),
                  trailing: const CircleAvatar(child: Text("A")),
                ),
                const Divider(height: 30),
                Text(
                  "Recommended For You",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.textColor,
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(height: 30),
                Text(
                  "Reviews",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.textColor,
                  ),
                ),
                const SizedBox(height: 6),
                ListTile(
                  leading: const CircleAvatar(child: Text("A")),
                  title: Text(
                    "I liked the product!",
                    style: TextStyle(color: theme.textColor),
                  ),
                  subtitle: Row(
                    children: List.generate(
                      5,
                      (_) => Icon(Icons.star, color: theme.starColor, size: 16),
                    ),
                  ),
                ),
                ListTile(
                  leading: const CircleAvatar(child: Text("A")),
                  title: Text(
                    "I liked the material!",
                    style: TextStyle(color: theme.textColor),
                  ),
                  subtitle: Row(
                    children: List.generate(
                      5,
                      (_) => Icon(Icons.star, color: theme.starColor, size: 16),
                    ),
                  ),
                ),
                ListTile(
                  leading: const CircleAvatar(child: Text("A")),
                  title: Text(
                    "Absolutely loved the design!",
                    style: TextStyle(color: theme.textColor),
                  ),
                  subtitle: Row(
                    children: List.generate(
                      5,
                      (_) => Icon(Icons.star, color: theme.starColor, size: 16),
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    "See More",
                    style: TextStyle(color: theme.buttonColor),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
