import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/language_model.dart';
import 'models/theme_model.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageModel>(context);
    final theme = Provider.of<ThemeModel>(context);

    return Scaffold(
      backgroundColor: theme.scaffoldColor,
      appBar: AppBar(
        title: Text(lang.isFilipino() ? 'Mag-login' : 'Login'),
        backgroundColor: theme.appBarColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              lang.isFilipino()
                  ? 'Maligayang Pagdating sa Shop It!'
                  : 'Welcome to Shop It!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.textColor,
              ),
            ),
            SizedBox(height: 32),
            TextField(
              decoration: InputDecoration(
                labelText: lang.isFilipino() ? 'Email' : 'Email',
                labelStyle: TextStyle(color: theme.textColor),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: lang.isFilipino() ? 'Password' : 'Password',
                labelStyle: TextStyle(color: theme.textColor),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.buttonColor,
                padding: EdgeInsets.symmetric(horizontal: 48, vertical: 12),
              ),
              child: Text(
                lang.isFilipino() ? 'Magpatuloy' : 'Continue',
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () {},
              child: Text(
                lang.isFilipino()
                    ? 'Nakalimutan ang password?'
                    : 'Forgot Password?',
                style: TextStyle(color: theme.textColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
