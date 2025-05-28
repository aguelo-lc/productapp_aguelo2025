import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/language_model.dart';
import 'models/theme_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'package:shared_preferences/shared_preferences.dart';

// LoginScreen is the entry point for user authentication
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controllers for email and password input fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  // State variables for loading, error, and password visibility
  bool _isLoading = false;
  String? _errorMessage;
  bool _isPasswordVisible = false;

  // Handles login logic, API call, and local storage
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
        // Save token using new API response
        if (data['access_token'] != null) {
          await prefs.setString('token', data['access_token']);
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
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 32.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App logo or icon
                Container(
                  decoration: BoxDecoration(
                    color: theme.buttonColor.withOpacity(0.08),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.buttonColor.withOpacity(0.15),
                        blurRadius: 16,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(24),
                  child: Icon(
                    Icons.shopping_bag_rounded,
                    size: 48,
                    color: theme.buttonColor,
                  ),
                ),
                SizedBox(height: 24),
                // Welcome text, localized
                Text(
                  lang.isFilipino()
                      ? 'Maligayang Pagdating sa Shop It!'
                      : 'Welcome to Shop It!',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: theme.textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),
                // Error message display
                if (_errorMessage != null) ...[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                ],
                // Login form card
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 28,
                    ),
                    child: Column(
                      children: [
                        // Email input
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: lang.isFilipino() ? 'Email' : 'Email',
                            labelStyle: TextStyle(
                              color: theme.textColor.withOpacity(0.7),
                            ),
                            filled: true,
                            fillColor: theme.scaffoldColor.withOpacity(0.5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: Icon(
                              Icons.email_rounded,
                              color: theme.buttonColor,
                            ),
                          ),
                          style: TextStyle(color: theme.textColor),
                        ),
                        SizedBox(height: 18),
                        // Password input with visibility toggle
                        TextField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            labelText:
                                lang.isFilipino() ? 'Password' : 'Password',
                            labelStyle: TextStyle(
                              color: theme.textColor.withOpacity(0.7),
                            ),
                            filled: true,
                            fillColor: theme.scaffoldColor.withOpacity(0.5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: Icon(
                              Icons.lock_rounded,
                              color: theme.buttonColor,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: theme.textColor.withOpacity(0.7),
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                          style: TextStyle(color: theme.textColor),
                        ),
                        SizedBox(height: 28),
                        // Login button with loading indicator
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                _isLoading ? null : () => _login(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.buttonColor,
                              padding: EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 2,
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
                                      lang.isFilipino()
                                          ? 'Magpatuloy'
                                          : 'Continue',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                          ),
                        ),
                        SizedBox(height: 16),
                        // Forgot password button (not yet implemented)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: Text(
                              lang.isFilipino()
                                  ? 'Nakalimutan ang password?'
                                  : 'Forgot Password?',
                              style: TextStyle(
                                color: theme.buttonColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
