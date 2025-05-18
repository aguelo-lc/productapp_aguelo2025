import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/language_model.dart';
import 'config.dart';

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
  List<dynamic> _categoriesApi = [];
  bool _isSubmitting = false;
  String? _errorMessage;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  int? _userId;

  @override
  void initState() {
    super.initState();
    fetchCategories();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('user_id');
    });
  }

  Future<void> fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/categories'),
      );
      if (response.statusCode == 200) {
        setState(() {
          _categoriesApi = jsonDecode(response.body);
        });
      }
    } catch (e) {
      // Optionally handle error
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> submitProduct() async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      var uri = Uri.parse('${AppConfig.baseUrl}/api/products');
      var request = http.MultipartRequest('POST', uri);
      request.fields['name'] = _productName;
      request.fields['description'] = _description;
      request.fields['price'] = _price;
      request.fields['category_id'] = _selectedCategory ?? '';
      request.fields['user_id'] =
          (_userId ?? 1).toString(); // Use logged-in user id, fallback to 1
      if (_selectedImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', _selectedImage!.path),
        );
      }
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Provider.of<LanguageModel>(context, listen: false).isFilipino()
                  ? 'Nagdagdag ng produkto'
                  : 'Product Added',
            ),
          ),
        );
        _formKey.currentState?.reset();
        setState(() {
          _selectedCategory = null;
          _selectedImage = null;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to add product.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Connection error.';
      });
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageModel>(context);

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
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (_errorMessage != null) ...[
                  Text(_errorMessage!, style: TextStyle(color: Colors.red)),
                  SizedBox(height: 8),
                ],
                GestureDetector(
                  onTap: pickImage,
                  child:
                      _selectedImage != null
                          ? Image.file(
                            _selectedImage!,
                            height: 120,
                            width: 120,
                            fit: BoxFit.cover,
                          )
                          : Container(
                            height: 120,
                            width: 120,
                            color: Colors.grey[300],
                            child: Icon(
                              Icons.camera_alt,
                              size: 40,
                              color: Colors.grey[700],
                            ),
                          ),
                ),
                SizedBox(height: 12),
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
                    labelText:
                        lang.isFilipino() ? 'Paglalarawan' : 'Description',
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
                      _categoriesApi.map<DropdownMenuItem<String>>((cat) {
                        return DropdownMenuItem<String>(
                          value: cat['id'].toString(),
                          child: Text(cat['name']),
                        );
                      }).toList(),
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
                  onPressed:
                      _isSubmitting
                          ? null
                          : () {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              submitProduct();
                            }
                          },
                  child:
                      _isSubmitting
                          ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : Text(lang.isFilipino() ? 'Isumite' : 'Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
