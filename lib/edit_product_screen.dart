import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';

class EditProductScreen extends StatefulWidget {
  // Screen for editing an existing product
  final Map<String, dynamic> product;
  const EditProductScreen({required this.product, super.key});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  // Form and state variables
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
    // Initialize form fields with product data
    _productName = widget.product['name'] ?? '';
    _price = widget.product['price']?.toString() ?? '';
    _description = widget.product['description'] ?? '';
    _selectedCategory = widget.product['category_id']?.toString();
    fetchCategories();
  }

  // Fetches categories for dropdown
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

  // Opens image picker for product image
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

  // Submits the edited product to the API
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
      appBar: AppBar(
        title: Text('Edit Product'),
        backgroundColor:
            Theme.of(context).appBarTheme.backgroundColor ?? Colors.white,
      ),
      body:
          _isSubmitting
              ? Center(child: CircularProgressIndicator()) // Show loading
              : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Product image picker
                      GestureDetector(
                        onTap: pickImage,
                        child:
                            _imageFile != null
                                ? ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.file(
                                    _imageFile!,
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  ),
                                )
                                : (widget.product['image_path'] != null &&
                                    widget.product['image_path']
                                        .toString()
                                        .isNotEmpty)
                                ? ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.network(
                                    '${AppConfig.baseUrl}/storage/${widget.product['image_path']}',
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  ),
                                )
                                : Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                      width: 1,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.camera_alt,
                                    size: 40,
                                    color: Colors.grey[500],
                                  ),
                                ),
                      ),
                      SizedBox(height: 18),
                      // Error message display
                      if (_errorMessage != null) ...[
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
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
                        SizedBox(height: 8),
                      ],
                      // Product name input
                      TextFormField(
                        initialValue: _productName,
                        decoration: InputDecoration(
                          labelText: 'Product Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        onChanged: (v) => _productName = v,
                        validator:
                            (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                      SizedBox(height: 14),
                      // Price input
                      TextFormField(
                        initialValue: _price,
                        decoration: InputDecoration(
                          labelText: 'Price',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (v) => _price = v,
                        validator:
                            (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                      SizedBox(height: 14),
                      // Description input
                      TextFormField(
                        initialValue: _description,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        onChanged: (v) => _description = v,
                      ),
                      SizedBox(height: 14),
                      // Category dropdown
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
                        decoration: InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        validator:
                            (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                      SizedBox(height: 24),
                      // Save button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : submitEdit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            'Save Changes',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
