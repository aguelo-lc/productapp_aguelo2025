import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/language_model.dart';

class LanguageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final languageModel = Provider.of<LanguageModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Select Language"),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          RadioListTile<String>(
            title: Text("English"),
            value: "English",
            groupValue: languageModel.language,
            onChanged: (val) {
              if (val != null) {
                languageModel.setLanguage(val);
                Navigator.pop(context);
              }
            },
          ),
          RadioListTile<String>(
            title: Text("Filipino"),
            value: "Filipino",
            groupValue: languageModel.language,
            onChanged: (val) {
              if (val != null) {
                languageModel.setLanguage(val);
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}
