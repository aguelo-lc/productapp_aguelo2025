import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login_screen.dart';
import 'models/language_model.dart';
import 'models/theme_model.dart';
import 'theme_screen.dart';
import 'language_screen.dart';
import 'widgets/main_screen.dart';
import 'user_profile_screen.dart';

void main() {
  // Set up providers for language and theme state management
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
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the current theme from the provider
    final theme = Provider.of<ThemeModel>(context);

    return MaterialApp(
      title: 'Shop It!',
      debugShowCheckedModeBanner: false, // Hide the debug banner
      theme: ThemeData(
        // Set scaffold and app bar colors from theme
        scaffoldBackgroundColor: theme.scaffoldColor,
        appBarTheme: AppBarTheme(backgroundColor: theme.appBarColor),
        // Apply text color from theme
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: theme.textColor,
          displayColor: theme.textColor,
        ),
        // Set button color from theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(backgroundColor: theme.buttonColor),
        ),
      ),
      initialRoute: '/', // Set initial route to login screen
      // Define app routes
      routes: {
        '/': (context) => LoginScreen(), // Login screen
        '/home': (context) => MainScreen(), // Main/home screen
        '/language': (context) => LanguageScreen(), // Language selection
        '/theme': (context) => ThemeScreen(), // Theme selection
        '/profile': (context) => UserProfileScreen(), // User profile
      },
    );
  }
}
