import 'package:flutter/material.dart';

class TrendingItem extends StatelessWidget {
  final String image;
  final String name;
  final String price;

  const TrendingItem({
    super.key,
    required this.image,
    required this.name,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      margin: EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(image, height: 120, width: 140, fit: BoxFit.cover),
          SizedBox(height: 6),
          Text(
            name,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          Text(price, style: TextStyle(color: Colors.red)),
        ],
      ),
    );
  }
}
