import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/language_model.dart';
import 'models/theme_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isPasswordVisible = false;

  Future<void> _login(BuildContext context) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final lang = Provider.of<LanguageModel>(context, listen: false);
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        if (data['user'] != null && data['user']['id'] != null) {
          await prefs.setInt('user_id', data['user']['id']);
          await prefs.setString('username', data['user']['username'] ?? '');
          await prefs.setString('email', data['user']['email'] ?? '');
        }
        // Save token if present
        if (data['token'] != null) {
          await prefs.setString('token', data['token']);
        }
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        final data = jsonDecode(response.body);
        setState(() {
          _errorMessage =
              data['message'] ??
              (lang.isFilipino()
                  ? 'Hindi matagumpay ang pag-login.'
                  : 'Login failed.');
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage =
            lang.isFilipino() ? 'May error sa koneksyon.' : 'Connection error.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

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
            if (_errorMessage != null) ...[
              Text(_errorMessage!, style: TextStyle(color: Colors.red)),
              SizedBox(height: 16),
            ],
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: lang.isFilipino() ? 'Email' : 'Email',
                labelStyle: TextStyle(color: theme.textColor),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: lang.isFilipino() ? 'Password' : 'Password',
                labelStyle: TextStyle(color: theme.textColor),
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: theme.textColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => _login(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.buttonColor,
                  padding: EdgeInsets.symmetric(horizontal: 48, vertical: 12),
                ),
                child:
                    _isLoading
                        ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : Text(
                          lang.isFilipino() ? 'Magpatuloy' : 'Continue',
                          style: TextStyle(color: Colors.white),
                        ),
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
