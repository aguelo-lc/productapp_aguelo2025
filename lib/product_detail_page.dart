import 'package:flutter/material.dart';

class ProductDetailPage extends StatelessWidget {
  final String name;
  final String price;
  final String image;
  final int rating;
  final String description;

  const ProductDetailPage({
    required this.name,
    required this.price,
    required this.image,
    required this.rating,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Shop It!"),
        backgroundColor: Colors.blue,
        actions: [
          CircleAvatar(
            backgroundColor: Colors.blue[900],
            child: Text("A", style: TextStyle(color: Colors.white)),
          ),
          SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(image),
            SizedBox(height: 12),
            Text(name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(price, style: TextStyle(fontSize: 18, color: Colors.red)),
            Row(
              children: List.generate(
                5,
                (index) => Icon(
                  Icons.star,
                  color: index < rating ? Colors.amber : Colors.grey[300],
                ),
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.shop_2),
              label: Text("Buy Product"),
            ),
            SizedBox(height: 12),
            Text("Description", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            Text(description),
            Divider(height: 30),
            ListTile(
              leading: Icon(Icons.store),
              title: Text("NC General Merchandise"),
              subtitle: Text("Cagayan de Oro City"),
              trailing: CircleAvatar(child: Text("A")),
            ),
            Divider(height: 30),
            Text("Recommended For You", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            // Add other product cards if needed
            Divider(height: 30),
            Text("Reviews", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            ListTile(
              leading: CircleAvatar(child: Text("A")),
              title: Text("I liked the product!"),
              subtitle: Row(
                children: List.generate(5, (_) => Icon(Icons.star, color: Colors.amber, size: 16)),
              ),
            ),
            ListTile(
              leading: CircleAvatar(child: Text("A")),
              title: Text("I liked the material!"),
              subtitle: Row(
                children: List.generate(5, (_) => Icon(Icons.star, color: Colors.amber, size: 16)),
              ),
            ),
            ListTile(
              leading: CircleAvatar(child: Text("A")),
              title: Text("Absolutely loved the design!"),
              subtitle: Row(
                children: List.generate(5, (_) => Icon(Icons.star, color: Colors.amber, size: 16)),
              ),
            ),
            Center(child: Text("See More", style: TextStyle(color: Colors.blue))),
          ],
        ),
        
      ),
    );
  }
}
