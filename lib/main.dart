import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_page.dart';
import 'login_screen.dart';
import 'models/language_model.dart';
import 'language_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(create: (_) => LanguageModel(), child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shop It!',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/home': (context) => HomePage(),
        '/language': (context) => LanguageScreen(),
      },
    );
  }
}
