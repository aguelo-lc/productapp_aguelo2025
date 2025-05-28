// lib/user_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/language_model.dart';
import 'models/theme_model.dart';
import 'package:http/http.dart' as http;
import 'config.dart';

class UserProfileScreen extends StatefulWidget {
  // Screen for displaying and managing user profile info
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  // User info state
  String? username;
  String? email;

  @override
  void initState() {
    super.initState();
    _loadUserInfo(); // Load user info from local storage
  }

  // Loads username and email from SharedPreferences
  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? '';
      email = prefs.getString('email') ?? '';
    });
  }

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
            // User avatar with initial
            CircleAvatar(
              radius: 50,
              backgroundColor: theme.buttonColor,
              child: Text(
                (username != null && username!.isNotEmpty)
                    ? username![0].toUpperCase()
                    : '',
                style: TextStyle(fontSize: 40, color: Colors.white),
              ),
            ),
            SizedBox(height: 16),
            // Username display
            Text(
              username ?? '',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.textColor,
              ),
            ),
            SizedBox(height: 8),
            // Email display
            Text(
              email ?? '',
              style: TextStyle(fontSize: 16, color: theme.textColor),
            ),
            SizedBox(height: 24),
            // Profile actions card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  // Edit profile option (not implemented)
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
                  Divider(height: 1),
                  // Logout option
                  ListTile(
                    leading: Icon(Icons.logout, color: theme.buttonColor),
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
                            headers: {'Authorization': 'Bearer $token'},
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
          ],
        ),
      ),
    );
  }
}
