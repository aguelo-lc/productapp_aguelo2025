import 'package:flutter/material.dart';

class ThemeModel extends ChangeNotifier {
  String _currentTheme = "default";

  Color _scaffoldBgColor = Colors.white;
  Color _appBarColor = Colors.blue;
  Color _drawerHeaderColor = Colors.blue;
  Color _buttonColor = Colors.blue;
  Color _textColor = Colors.black;
  Color _ratingColor = Colors.amber; // Default star color

  void applyPurpleTheme() {
    _currentTheme = "purple";
    _scaffoldBgColor = Colors.white;
    _appBarColor = Colors.deepPurple;
    _drawerHeaderColor = Colors.deepPurple.shade700;
    _buttonColor = const Color.fromARGB(255, 249, 110, 30);
    _textColor = Colors.deepPurple;
    _ratingColor = Color.fromRGBO(255, 0, 153, 1); // Purple star

    notifyListeners();
  }

  void resetTheme() {
    _currentTheme = "default";
    _scaffoldBgColor = Colors.white;
    _appBarColor = Colors.blue;
    _drawerHeaderColor = Colors.blue;
    _buttonColor = Colors.blue;
    _textColor = Colors.black;
    _ratingColor = Colors.amber;
    notifyListeners();
  }

  String get currentTheme => _currentTheme;
  Color get scaffoldColor => _scaffoldBgColor;
  Color get appBarColor => _appBarColor;
  Color get drawerHeaderColor => _drawerHeaderColor;
  Color get buttonColor => _buttonColor;
  Color get textColor => _textColor;
  Color get starColor => _ratingColor;
}
