import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/language_model.dart';
import 'models/theme_model.dart';
import 'widgets/category_tile.dart';
import 'widgets/trending_item.dart';
import 'widgets/recommended_item.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageModel>(context);
    final theme = Provider.of<ThemeModel>(context);

    final List<Map<String, dynamic>> categories = [
      {
        'icon': Icons.checkroom,
        'label': lang.isFilipino() ? 'Damit' : 'Clothes',
      },
      {
        'icon': Icons.weekend,
        'label': lang.isFilipino() ? 'Kagamitan sa Bahay' : 'Furnitures',
      },
      {
        'icon': Icons.electrical_services,
        'label': lang.isFilipino() ? 'Elektroniko' : 'Electronics',
      },
      {
        'icon': Icons.grass,
        'label': lang.isFilipino() ? 'Panghalaman' : 'Garden Materials',
      },
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

    return Scaffold(
      backgroundColor: theme.scaffoldColor,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: theme.drawerHeaderColor),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: theme.buttonColor,
                    child: Text("A", style: TextStyle(color: Colors.white)),
                  ),
                  SizedBox(width: 16),
                  Text(
                    lang.isFilipino() ? "Maligayang pagdating!" : "Welcome!",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.color_lens, color: theme.textColor),
              title: Text(
                lang.isFilipino() ? 'Tema' : 'Theme',
                style: TextStyle(color: theme.textColor),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/theme');
              },
            ),
            ListTile(
              leading: Icon(Icons.language, color: theme.textColor),
              title: Text(
                lang.isFilipino() ? 'Wika' : 'Language',
                style: TextStyle(color: theme.textColor),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/language');
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: theme.textColor),
              title: Text(
                lang.isFilipino() ? 'Mag-logout' : 'Logout',
                style: TextStyle(color: theme.textColor),
              ),
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
                    child: Icon(Icons.home, color: Colors.white),
                  ),
                  SizedBox(width: 8),
                  Text(lang.isFilipino() ? "Mamili Na!" : "Shop It!"),
                  Spacer(),
                  CircleAvatar(
                    backgroundColor: theme.buttonColor,
                    child: Text("A", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
        ),
        backgroundColor: theme.appBarColor,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText:
                    lang.isFilipino()
                        ? 'Ano ang kailangan mo?'
                        : 'What do you need?',
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
                  lang.isFilipino() ? "Mga Kategorya" : "Categories",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.textColor,
                  ),
                ),
                Spacer(),
                Text(
                  lang.isFilipino() ? "Tingnan Lahat" : "See All",
                  style: TextStyle(color: theme.buttonColor),
                ),
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
            Text(
              lang.isFilipino() ? "Uso Ngayon" : "Trending",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.textColor,
              ),
            ),
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
              lang.isFilipino()
                  ? "Inirerekomenda Para Sa Iyo"
                  : "Recommended For You",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.textColor,
              ),
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
                              lang.isFilipino()
                                  ? 'Ang headband ay isang aksesorya na isinusuot sa buhok...'
                                  : 'A headband or hairband is a clothing accessory worn in the hair...',
                        ),
                      )
                      .toList(),
            ),
            Center(
              child: Text(
                lang.isFilipino() ? "Tingnan Lahat" : "See All",
                style: TextStyle(color: theme.buttonColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
