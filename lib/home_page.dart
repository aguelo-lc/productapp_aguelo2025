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
import 'my_products_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
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
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final lang = Provider.of<LanguageModel>(context);
    final theme = Provider.of<ThemeModel>(context);

    return Scaffold(
      backgroundColor: theme.scaffoldColor,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: theme.drawerHeaderColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: theme.buttonColor,
                    child: Text(
                      "A",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Text(
                      lang.isFilipino() ? "Maligayang pagdating!" : "Welcome!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
              leading: Icon(Icons.category, color: theme.textColor),
              title: Text(
                lang.isFilipino() ? 'Mga Kategorya' : 'Categories',
                style: TextStyle(color: theme.textColor),
              ),
              onTap: () {
                Navigator.pop(context);
                if (categoriesApi.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => CategoryProductsScreen(
                            initialCategory: categoriesApi[0],
                            allCategories: categoriesApi,
                          ),
                    ),
                  );
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.inventory, color: theme.textColor),
              title: Text(
                lang.isFilipino() ? 'Aking Mga Produkto' : 'My Products',
                style: TextStyle(color: theme.textColor),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyProductsScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: theme.textColor),
              title: Text(
                lang.isFilipino() ? 'Mag-logout' : 'Logout',
                style: TextStyle(color: theme.textColor),
              ),
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                final token = prefs.getString('token');
                if (token != null) {
                  try {
                    await http.post(
                      Uri.parse('${AppConfig.baseUrl}/api/auth/logout'),
                      headers: {
                        'Content-Type': 'application/json',
                        'Authorization': 'Bearer $token',
                      },
                    );
                  } catch (e) {
                    // Optionally handle error
                  }
                  await prefs.remove('token');
                  await prefs.remove('user_id');
                  await prefs.remove('username');
                  await prefs.remove('email');
                }
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
        ),
        title: Builder(
          builder:
              (context) => Row(
                children: [
                  GestureDetector(
                    onTap: () => Scaffold.of(context).openDrawer(),
                    child: Icon(Icons.home, color: Colors.white, size: 28),
                  ),
                  SizedBox(width: 12),
                  Text(
                    lang.isFilipino() ? "Mamili Na!" : "Shop It!",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                  Spacer(),
                  CircleAvatar(
                    backgroundColor: theme.buttonColor,
                    child: Text(
                      "A",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
              ? Center(
                child: Text(
                  errorMessage!,
                  style: TextStyle(fontSize: 18, color: Colors.red),
                ),
              )
              : RefreshIndicator(
                onRefresh: () async {
                  await fetchProducts();
                  await fetchCategories();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: theme.scaffoldColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText:
                                lang.isFilipino()
                                    ? 'Ano ang kailangan mo?'
                                    : 'What do you need?',
                            prefixIcon: Icon(
                              Icons.search,
                              color: theme.buttonColor,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 18),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          height: 200,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            "assets/images/cyber_monday.jpg",
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      ),
                      SizedBox(height: 28),
                      Row(
                        children: [
                          Text(
                            lang.isFilipino() ? "Mga Kategorya" : "Categories",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: theme.textColor,
                              fontSize: 18,
                            ),
                          ),
                          Spacer(),
                          Text(
                            lang.isFilipino() ? "Tingnan Lahat" : "See All",
                            style: TextStyle(
                              color: theme.buttonColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      SizedBox(
                        height: 100,
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
                                    padding: const EdgeInsets.only(right: 18.0),
                                    child: SizedBox(
                                      width: 80,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 56,
                                            height: 56,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black12,
                                                  blurRadius: 6,
                                                  offset: Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                            clipBehavior: Clip.hardEdge,
                                            child:
                                                cat['image_path'] != null &&
                                                        cat['image_path']
                                                            .toString()
                                                            .isNotEmpty
                                                    ? Image.network(
                                                      '${AppConfig.baseUrl}/storage/${cat['image_path']}',
                                                      width: 56,
                                                      height: 56,
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
                                          SizedBox(height: 6),
                                          Flexible(
                                            child: Text(
                                              cat['name'] ?? '',
                                              style: TextStyle(
                                                color: theme.textColor,
                                                fontWeight: FontWeight.w500,
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
                      SizedBox(height: 28),
                      // Trending Section
                      Text(
                        lang.isFilipino() ? "Uso Ngayon" : "Trending",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.textColor,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children:
                              getRandomProducts(6)
                                  .map(
                                    (item) => TrendingItem(
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
                                  )
                                  .toList(),
                        ),
                      ),
                      SizedBox(height: 28),
                      // Recommended Section
                      Text(
                        lang.isFilipino()
                            ? "Inirerekomenda Para Sa Iyo"
                            : "Recommended For You",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.textColor,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 12),
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
                                    rating: 5,
                                    description: item['description'] ?? '',
                                  ),
                                )
                                .toList(),
                      ),
                      SizedBox(height: 28),
                      // Hot Deals Section
                      Text(
                        lang.isFilipino() ? "Mainit na Deal" : "Hot Deals",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.textColor,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children:
                              getRandomProducts(6)
                                  .map(
                                    (item) => TrendingItem(
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
                                  )
                                  .toList(),
                        ),
                      ),
                      SizedBox(height: 28),
                      // Admin's Picks Section
                      Text(
                        lang.isFilipino() ? "Pinili ng Admin" : "Admin's Picks",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.textColor,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 12),
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
                      SizedBox(height: 32),
                      Center(
                        child: Text(
                          lang.isFilipino() ? "Tingnan Lahat" : "See All",
                          style: TextStyle(
                            color: theme.buttonColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
    );
  }
}

// Beautified TrendingItem
class TrendingItem extends StatelessWidget {
  final String image;
  final String name;
  final String price;
  final String description;

  const TrendingItem({
    super.key,
    required this.image,
    required this.name,
    required this.price,
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
                  rating: 5,
                  description: description,
                ),
          ),
        );
      },
      child: Container(
        width: 180,
        margin: EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              child:
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
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: theme.textColor,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    price,
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Beautified RecommendedItem
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
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child:
                image.startsWith('http')
                    ? Image.network(
                      image,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    )
                    : Image.asset(
                      image,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
          ),
          title: Text(
            name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.textColor,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                price,
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
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
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final int _currentIndex = 0;

  final List<Widget Function()> _screenBuilders = [
    () => HomePage(),
    () => AddProductScreen(),
    () => UserProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: List.generate(
          _screenBuilders.length,
          (i) => _screenBuilders[i](),
        ),
      ),
    );
  }
}

class CategoryTile extends StatelessWidget {
  final IconData icon;
  final String label;

  const CategoryTile({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(children: [Icon(icon), SizedBox(height: 4), Text(label)]);
  }
}
