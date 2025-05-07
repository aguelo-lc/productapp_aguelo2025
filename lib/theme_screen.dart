import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/theme_model.dart';
import 'models/language_model.dart';

class ThemeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);
    final lang = Provider.of<LanguageModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.isFilipino() ? 'Pumili ng Tema' : 'Select Theme'),
        backgroundColor: themeModel.appBarColor,
      ),
      body: Column(
        children: [
          RadioListTile<String>(
            title: Text(
              lang.isFilipino() ? "Default na Tema" : "Default Theme",
            ),
            value: "default",
            groupValue: themeModel.currentTheme,
            onChanged: (val) {
              if (val == "default") themeModel.resetTheme();
              Navigator.pop(context);
            },
          ),
          RadioListTile<String>(
            title: Text(lang.isFilipino() ? "Lilang Tema" : "Purple Theme"),
            value: "purple",
            groupValue: themeModel.currentTheme,
            onChanged: (val) {
              if (val == "purple") themeModel.applyPurpleTheme();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
