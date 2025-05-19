import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';

class EditProductScreen extends StatefulWidget {
  final Map<String, dynamic> product;
  EditProductScreen({required this.product, Key? key}) : super(key: key);

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _productName;
  late String _price;
  late String _description;
  String? _selectedCategory;
  File? _imageFile;
  bool _isSubmitting = false;
  String? _errorMessage;
  List<dynamic> _categories = [];

  @override
  void initState() {
    super.initState();
    _productName = widget.product['name'] ?? '';
    _price = widget.product['price']?.toString() ?? '';
    _description = widget.product['description'] ?? '';
    _selectedCategory = widget.product['category_id']?.toString();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/api/categories'),
    );
    if (response.statusCode == 200) {
      setState(() {
        _categories = List.from(jsonDecode(response.body));
      });
    }
  }

  bool _isPickingImage = false;

  Future<void> pickImage() async {
    if (_isPickingImage) return; // Prevent re-entry
    setState(() => _isPickingImage = true);
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        setState(() {
          _imageFile = File(picked.path);
        });
      }
    } finally {
      setState(() => _isPickingImage = false);
    }
  }

  Future<void> submitEdit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    if (userId == null) return;

    var uri = Uri.parse(
      '${AppConfig.baseUrl}/api/products/${widget.product['id']}',
    );
    var request = http.MultipartRequest(
      'POST',
      uri,
    ); // Laravel expects POST + _method=PUT

    request.fields['name'] = _productName;
    request.fields['price'] = _price;
    request.fields['description'] = _description;
    request.fields['category_id'] = _selectedCategory ?? '';
    request.fields['user_id'] = userId.toString();
    request.fields['_method'] = 'PUT';

    if (_imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', _imageFile!.path),
      );
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    setState(() => _isSubmitting = false);

    if (response.statusCode == 200) {
      Navigator.pop(context, true);
    } else {
      setState(() => _errorMessage = 'Failed to update product.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Product')),
      body:
          _isSubmitting
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: pickImage,
                        child:
                            _imageFile != null
                                ? Image.file(
                                  _imageFile!,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                )
                                : (widget.product['image_path'] != null &&
                                    widget.product['image_path']
                                        .toString()
                                        .isNotEmpty)
                                ? Image.network(
                                  '${AppConfig.baseUrl}/storage/${widget.product['image_path']}',
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                )
                                : Container(
                                  width: 120,
                                  height: 120,
                                  color: Colors.grey[300],
                                  child: Icon(Icons.camera_alt, size: 40),
                                ),
                      ),
                      TextFormField(
                        initialValue: _productName,
                        decoration: InputDecoration(labelText: 'Product Name'),
                        onChanged: (v) => _productName = v,
                        validator:
                            (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                      TextFormField(
                        initialValue: _price,
                        decoration: InputDecoration(labelText: 'Price'),
                        keyboardType: TextInputType.number,
                        onChanged: (v) => _price = v,
                        validator:
                            (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                      TextFormField(
                        initialValue: _description,
                        decoration: InputDecoration(labelText: 'Description'),
                        onChanged: (v) => _description = v,
                      ),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        items:
                            _categories
                                .map<DropdownMenuItem<String>>(
                                  (cat) => DropdownMenuItem(
                                    value: cat['id'].toString(),
                                    child: Text(cat['name']),
                                  ),
                                )
                                .toList(),
                        onChanged: (v) => setState(() => _selectedCategory = v),
                        decoration: InputDecoration(labelText: 'Category'),
                        validator:
                            (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _isSubmitting ? null : submitEdit,
                        child: Text('Save Changes'),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
