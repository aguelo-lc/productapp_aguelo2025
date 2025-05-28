import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/language_model.dart';

class LanguageScreen extends StatelessWidget {
  // Screen for selecting and applying app language
  const LanguageScreen({super.key});

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
          // Option for English language
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
          // Option for Filipino language
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
