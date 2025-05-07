// lib/user_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/language_model.dart';
import 'models/theme_model.dart';

class UserProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageModel>(context);
    final theme = Provider.of<ThemeModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.isFilipino() ? 'Aking Profile' : 'My Profile'),
        backgroundColor: theme.appBarColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: theme.buttonColor,
              child: Text(
                'A',
                style: TextStyle(fontSize: 40, color: Colors.white),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Alex Dela Cruz',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.textColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'alex@example.com',
              style: TextStyle(fontSize: 16, color: theme.textColor),
            ),
            SizedBox(height: 24),
            ListTile(
              leading: Icon(Icons.edit, color: theme.buttonColor),
              title: Text(
                lang.isFilipino() ? 'I-edit ang Profile' : 'Edit Profile',
                style: TextStyle(color: theme.textColor),
              ),
              onTap: () {
                // Navigate to edit profile screen
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: theme.buttonColor),
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
    );
  }
}
