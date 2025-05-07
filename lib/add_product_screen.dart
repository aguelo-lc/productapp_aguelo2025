import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/language_model.dart';

class AddProductScreen extends StatefulWidget {
  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  String _productName = '';
  String _price = '';
  String _description = '';
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageModel>(context);

    final List<String> _categories =
        lang.isFilipino()
            ? ['Damit', 'Kagamitan sa Bahay', 'Elektroniko', 'Panghalaman']
            : ['Clothes', 'Furnitures', 'Electronics', 'Garden Materials'];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          lang.isFilipino() ? 'Magdagdag ng Produkto' : 'Add Product',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText:
                      lang.isFilipino()
                          ? 'Pangalan ng Produkto'
                          : 'Product Name',
                ),
                onSaved: (value) => _productName = value ?? '',
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? (lang.isFilipino()
                                ? 'Ilagay ang pangalan'
                                : 'Enter product name')
                            : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: lang.isFilipino() ? 'Presyo' : 'Price',
                ),
                keyboardType: TextInputType.number,
                onSaved: (value) => _price = value ?? '',
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? (lang.isFilipino()
                                ? 'Ilagay ang presyo'
                                : 'Enter price')
                            : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: lang.isFilipino() ? 'Paglalarawan' : 'Description',
                ),
                onSaved: (value) => _description = value ?? '',
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? (lang.isFilipino()
                                ? 'Ilagay ang paglalarawan'
                                : 'Enter description')
                            : null,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: lang.isFilipino() ? 'Kategorya' : 'Category',
                ),
                value: _selectedCategory,
                items:
                    _categories
                        .map(
                          (category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? (lang.isFilipino()
                                ? 'Pumili ng kategorya'
                                : 'Select a category')
                            : null,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          lang.isFilipino()
                              ? 'Nagdagdag ng produkto'
                              : 'Product Added',
                        ),
                      ),
                    );
                  }
                },
                child: Text(lang.isFilipino() ? 'Isumite' : 'Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
