import 'package:flutter/material.dart';
import 'package:productapp_aguelo2025/models/theme_model.dart';
import 'package:provider/provider.dart';
import '../product_detail_page.dart'; // Adjust if needed

class RecommendedItem extends StatelessWidget {
  final String image;
  final String name;
  final String price;
  final int rating;
  final String description;

  const RecommendedItem({
    super.key,
    required this.image,
    required this.name,
    required this.price,
    required this.rating,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeModel>(context);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ProductDetailPage(
                  name: name,
                  price: price,
                  image: image,
                  rating: rating,
                  description: description,
                ),
          ),
        );
      },
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 6),
        leading: Image.asset(image, width: 80, height: 80, fit: BoxFit.cover),
        title: Text(name, style: TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(price, style: TextStyle(color: Colors.red)),
            Row(
              children: List.generate(
                5,
                (index) => Icon(
                  Icons.star,
                  size: 16,
                  color: index < rating ? theme.starColor : Colors.grey[300],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
