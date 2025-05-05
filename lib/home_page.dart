import 'package:flutter/material.dart';
import 'widgets/category_tile.dart';
import 'widgets/trending_item.dart';
import 'widgets/recommended_item.dart';

class HomePage extends StatelessWidget {
  final List<Map<String, dynamic>> categories = [
    {'icon': Icons.checkroom, 'label': 'Clothes'},
    {'icon': Icons.weekend, 'label': 'Furnitures'},
    {'icon': Icons.electrical_services, 'label': 'Electronics'},
    {'icon': Icons.grass, 'label': 'Garden Materials'},
  ];

  final List<Map<String, String>> trending = [
    {
      'name': 'Random Blocks',
      'price': '₱100',
      'image': 'assets/images/random_blocks.jpg',
    },
    {
      'name': 'LEGO Towers',
      'price': '₱250',
      'image': 'assets/images/lego_towers.jpg',
    },
    {
      'name': 'Couple Rings',
      'price': '₱200',
      'image': 'assets/images/couple_rings.jpg',
    },
    {
      'name': 'Sunglasses',
      'price': '₱150',
      'image': 'assets/images/sunglasses.jpg',
    },
  ];

  final List<Map<String, dynamic>> recommended = [
    {
      'name': 'Hair Brush Set',
      'price': '₱99',
      'image': 'assets/images/hair_brush.jpg',
      'rating': 5,
    },
    {
      'name': 'Fountain Pen',
      'price': '₱69',
      'image': 'assets/images/fountain_pen.jpg',
      'rating': 4,
    },
    {
      'name': 'Blue Wig Synthetic',
      'price': '₱799',
      'image': 'assets/images/blue_wig.jpg',
      'rating': 5,
    },
    {
      'name': 'Gold Pet Collar',
      'price': '₱129',
      'image': 'assets/images/gold_collar.jpg',
      'rating': 5,
    },
    {
      'name': 'Artsy Hair Clips',
      'price': '₱79',
      'image': 'assets/images/hair_clips.jpg',
      'rating': 4,
    },
    {
      'name': 'Cutie Headbands',
      'price': '₱49',
      'image': 'assets/images/headbands.jpg',
      'rating': 4,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue[900],
                    child: Text("A", style: TextStyle(color: Colors.white)),
                  ),
                  SizedBox(width: 16),
                  Text(
                    "Welcome!",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.color_lens),
              title: Text('Theme'),
              onTap: () {
                Navigator.pop(context);
                // implement theme change
              },
            ),
            ListTile(
              leading: Icon(Icons.language),
              title: Text('Language'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Builder(
          builder:
              (context) => Row(
                children: [
                  GestureDetector(
                    onTap: () => Scaffold.of(context).openDrawer(),
                    child: Icon(Icons.home),
                  ),
                  SizedBox(width: 8),
                  Text("Shop It!"),
                  Spacer(),
                  CircleAvatar(
                    backgroundColor: Colors.blue[900],
                    child: Text("A", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
        ),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'What do you need?',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 12),
            Container(
              height: 200,
              margin: EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: AssetImage("assets/images/cyber_monday.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Text(
                  "Categories",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Text("See All", style: TextStyle(color: Colors.blue)),
              ],
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 16,
              children:
                  categories
                      .map(
                        (cat) => CategoryTile(
                          icon: cat['icon'],
                          label: cat['label'],
                        ),
                      )
                      .toList(),
            ),
            SizedBox(height: 20),
            Text("Trending", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    trending
                        .map(
                          (item) => TrendingItem(
                            image: item['image']!,
                            name: item['name']!,
                            price: item['price']!,
                          ),
                        )
                        .toList(),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Recommended For You",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Column(
              children:
                  recommended
                      .map(
                        (item) => RecommendedItem(
                          image: item['image'],
                          name: item['name'],
                          price: item['price'],
                          rating: item['rating'],
                          description:
                              'A headband or hairband is a clothing accessory worn in the hair...',
                        ),
                      )
                      .toList(),
            ),
            Center(
              child: Text("See All", style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
      ),
    );
  }
}
