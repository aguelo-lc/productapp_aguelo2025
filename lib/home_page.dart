import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config.dart';
import 'models/language_model.dart';
import 'models/theme_model.dart';
import 'product_detail_page.dart';
import 'add_product_screen.dart';
import 'user_profile_screen.dart';
import 'category_products_screen.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> products = [];
  List<dynamic> categoriesApi = [];
  bool isLoading = true;
  String? errorMessage;

  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    fetchProducts();
    fetchCategories();
  }

  Future<void> fetchProducts() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/products?all=1'),
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

  Future<void> fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/categories'),
      );
      if (response.statusCode == 200) {
        setState(() {
          categoriesApi = jsonDecode(response.body);
        });
      }
    } catch (e) {
      // Optionally handle error
    }
  }

  List<dynamic> getRandomProducts(int count) {
    if (products.length <= count) return List.from(products);
    final List<dynamic> copy = List.from(products);
    copy.shuffle(_random);
    return copy.take(count).toList();
  }

  List<dynamic> getRandomCategories(int count) {
    if (categoriesApi.length <= count) return List.from(categoriesApi);
    final List<dynamic> copy = List.from(categoriesApi);
    copy.shuffle(_random);
    return copy.take(count).toList();
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageModel>(context);
    final theme = Provider.of<ThemeModel>(context);

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
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : RefreshIndicator(
                onRefresh: () async {
                  await fetchProducts();
                  await fetchCategories();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
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
                      SizedBox(
                        height: 90,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children:
                              getRandomCategories(8).map((cat) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => CategoryProductsScreen(
                                              initialCategory: cat,
                                              allCategories: categoriesApi,
                                            ),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 16.0),
                                    child: SizedBox(
                                      width: 72,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 48,
                                            height: 48,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            clipBehavior: Clip.hardEdge,
                                            child:
                                                cat['image_path'] != null &&
                                                        cat['image_path']
                                                            .toString()
                                                            .isNotEmpty
                                                    ? Image.network(
                                                      '${AppConfig.baseUrl}/storage/${cat['image_path']}',
                                                      width: 48,
                                                      height: 48,
                                                      fit: BoxFit.cover,
                                                      errorBuilder:
                                                          (
                                                            context,
                                                            error,
                                                            stackTrace,
                                                          ) => Icon(
                                                            Icons.broken_image,
                                                            size: 32,
                                                          ),
                                                    )
                                                    : Icon(
                                                      Icons.category,
                                                      size: 32,
                                                    ),
                                          ),
                                          SizedBox(height: 4),
                                          Flexible(
                                            child: Text(
                                              cat['name'] ?? '',
                                              style: TextStyle(
                                                color: theme.textColor,
                                              ),
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
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
                              getRandomProducts(6)
                                  .map(
                                    (item) => GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => ProductDetailPage(
                                                  name: item['name'] ?? '',
                                                  price: '₱${item['price']}',
                                                  image:
                                                      item['image_path'] !=
                                                                  null &&
                                                              item['image_path']
                                                                  .toString()
                                                                  .isNotEmpty
                                                          ? '${AppConfig.baseUrl}/storage/${item['image_path']}'
                                                          : 'assets/images/product_placeholder.png',
                                                  rating: 5, // Default rating
                                                  description:
                                                      item['description'] ?? '',
                                                  category:
                                                      item['category'] ?? null,
                                                  allCategories: categoriesApi,
                                                ),
                                          ),
                                        );
                                      },
                                      child: TrendingItem(
                                        image:
                                            item['image_path'] != null &&
                                                    item['image_path']
                                                        .toString()
                                                        .isNotEmpty
                                                ? '${AppConfig.baseUrl}/storage/${item['image_path']}'
                                                : 'assets/images/product_placeholder.png',
                                        name: item['name'] ?? '',
                                        price: '₱${item['price']}',
                                        description: item['description'] ?? '',
                                      ),
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
                            getRandomProducts(6)
                                .map(
                                  (item) => RecommendedItem(
                                    image:
                                        item['image_path'] != null
                                            ? '${AppConfig.baseUrl}/storage/${item['image_path']}'
                                            : 'assets/images/product_placeholder.png',
                                    name: item['name'] ?? '',
                                    price: '₱${item['price']}',
                                    rating:
                                        5, // You can update this if you have ratings
                                    description: item['description'] ?? '',
                                  ),
                                )
                                .toList(),
                      ),
                      SizedBox(height: 20),
                      Text(
                        lang.isFilipino() ? "Mainit na Deal" : "Hot Deals",
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
                              getRandomProducts(6)
                                  .map(
                                    (item) => GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => ProductDetailPage(
                                                  name: item['name'] ?? '',
                                                  price: '₱${item['price']}',
                                                  image:
                                                      item['image_path'] !=
                                                                  null &&
                                                              item['image_path']
                                                                  .toString()
                                                                  .isNotEmpty
                                                          ? '${AppConfig.baseUrl}/storage/${item['image_path']}'
                                                          : 'assets/images/product_placeholder.png',
                                                  rating: 5, // Default rating
                                                  description:
                                                      item['description'] ?? '',
                                                  category:
                                                      item['category'] ?? null,
                                                  allCategories: categoriesApi,
                                                ),
                                          ),
                                        );
                                      },
                                      child: TrendingItem(
                                        image:
                                            item['image_path'] != null &&
                                                    item['image_path']
                                                        .toString()
                                                        .isNotEmpty
                                                ? '${AppConfig.baseUrl}/storage/${item['image_path']}'
                                                : 'assets/images/product_placeholder.png',
                                        name: item['name'] ?? '',
                                        price: '₱${item['price']}',
                                        description: item['description'] ?? '',
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        lang.isFilipino() ? "Pinili ng Admin" : "Admin's Picks",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.textColor,
                        ),
                      ),
                      SizedBox(height: 8),
                      Column(
                        children:
                            getRandomProducts(5)
                                .map(
                                  (item) => RecommendedItem(
                                    image:
                                        item['image_path'] != null
                                            ? '${AppConfig.baseUrl}/storage/${item['image_path']}'
                                            : 'assets/images/product_placeholder.png',
                                    name: item['name'] ?? '',
                                    price: '₱${item['price']}',
                                    rating: 5,
                                    description: item['description'] ?? '',
                                  ),
                                )
                                .toList(),
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: Text(
                          lang.isFilipino() ? "Tingnan Lahat" : "See All",
                          style: TextStyle(color: theme.buttonColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}

class TrendingItem extends StatelessWidget {
  final String image;
  final String name;
  final String price;
  final String description;

  const TrendingItem({
    required this.image,
    required this.name,
    required this.price,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
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
                  rating: 5, // Default rating, update if you have ratings
                  description: description,
                ),
          ),
        );
      },
      child: Container(
        width: 180,
        margin: EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            image.startsWith('http')
                ? Image.network(
                  image,
                  height: 120,
                  width: 180,
                  fit: BoxFit.cover,
                )
                : Image.asset(
                  image,
                  height: 120,
                  width: 180,
                  fit: BoxFit.cover,
                ),
            SizedBox(height: 6),
            Text(
              name,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            Text(price, style: TextStyle(color: Colors.red)),
            Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

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
        leading:
            image.startsWith('http')
                ? Image.network(image, width: 80, height: 80, fit: BoxFit.cover)
                : Image.asset(image, width: 80, height: 80, fit: BoxFit.cover),
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
            Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomePage(),
    AddProductScreen(),
    UserProfileScreen(), // Placeholder
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box),
            label: 'Add Product',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class CategoryTile extends StatelessWidget {
  final IconData icon;
  final String label;

  const CategoryTile({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(children: [Icon(icon), SizedBox(height: 4), Text(label)]);
  }
}
