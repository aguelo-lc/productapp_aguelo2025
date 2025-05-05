import 'package:flutter/material.dart';
import '../product_detail_page.dart'; // Adjust if needed

class RecommendedItem extends StatelessWidget {
  final String image;
  final String name;
  final String price;
  final int rating;
  final String description;

  const RecommendedItem({
    required this.image,
    required this.name,
    required this.price,
    required this.rating,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(
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
                  color: index < rating ? Colors.yellow : Colors.grey[300],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
