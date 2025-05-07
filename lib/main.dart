import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login_screen.dart';
import 'models/language_model.dart';
import 'models/theme_model.dart';
import 'theme_screen.dart';
import 'language_screen.dart';
import 'widgets/main_screen.dart';
import 'user_profile_screen.dart'; // <-- Import MainScreen

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageModel()),
        ChangeNotifierProvider(create: (_) => ThemeModel()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeModel>(context);

    return MaterialApp(
      title: 'Shop It!',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: theme.scaffoldColor,
        appBarTheme: AppBarTheme(backgroundColor: theme.appBarColor),
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: theme.textColor,
          displayColor: theme.textColor,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(backgroundColor: theme.buttonColor),
        ),
      ),
      initialRoute: '/',
      // main.dart
      // Add this import

      // Inside MaterialApp
      routes: {
        '/': (context) => LoginScreen(),
        '/home': (context) => MainScreen(),
        '/language': (context) => LanguageScreen(),
        '/theme': (context) => ThemeScreen(),
        '/profile': (context) => UserProfileScreen(), // Add this route
      },
    );
  }
}
