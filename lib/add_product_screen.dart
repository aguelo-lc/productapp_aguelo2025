import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/language_model.dart';
import 'config.dart';

// Screen for adding a new product (optionally for editing if product is provided)
class AddProductScreen extends StatefulWidget {
  final Map<String, dynamic>? product;

  const AddProductScreen({this.product, super.key});

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen>
    with AutomaticKeepAliveClientMixin {
  // Form and state variables
  final _formKey = GlobalKey<FormState>();
  String _productName = '';
  String _price = '';
  String _description = '';
  String? _selectedCategory;
  List<dynamic> _categoriesApi = [];
  bool _isSubmitting = false;
  String? _errorMessage;
  File? _selectedImage;
  int? _userId;

  @override
  void initState() {
    super.initState();
    // If editing, initialize fields with product data
    if (widget.product != null) {
      _productName = widget.product!['name'] ?? '';
      _price = widget.product!['price']?.toString() ?? '';
      _description = widget.product!['description'] ?? '';
      _selectedCategory = widget.product!['category_id']?.toString();
      // Optionally handle image if you want to show it for editing
    }
    fetchCategories(); // Load categories for dropdown
    _loadUserId(); // Load user ID from local storage
  }

  // Loads user ID from SharedPreferences
  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('user_id');
    });
  }

  // Fetches product categories from API
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
          _selectedImage = File(picked.path);
        });
      }
    } finally {
      setState(() => _isPickingImage = false);
    }
  }

  // Submits the new product to the API
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
        // Show success message and reset form
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
  bool get wantKeepAlive => true; // Keep state alive in tab navigation

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final lang = Provider.of<LanguageModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          lang.isFilipino() ? 'Magdagdag ng Produkto' : 'Add Product',
        ),
        backgroundColor:
            Theme.of(context).appBarTheme.backgroundColor ?? Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
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
                  SizedBox(height: 8),
                ],
                // Product image picker
                GestureDetector(
                  onTap: pickImage,
                  child:
                      _selectedImage != null
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(
                              _selectedImage!,
                              height: 120,
                              width: 120,
                              fit: BoxFit.cover,
                            ),
                          )
                          : Container(
                            height: 120,
                            width: 120,
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
                // Product name input
                TextFormField(
                  initialValue: _productName,
                  decoration: InputDecoration(
                    labelText:
                        lang.isFilipino()
                            ? 'Pangalan ng Produkto'
                            : 'Product Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  onChanged: (v) => _productName = v,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                SizedBox(height: 14),
                // Price input
                TextFormField(
                  initialValue: _price,
                  decoration: InputDecoration(
                    labelText: lang.isFilipino() ? 'Presyo' : 'Price',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => _price = v,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                SizedBox(height: 14),
                // Description input
                TextFormField(
                  initialValue: _description,
                  decoration: InputDecoration(
                    labelText:
                        lang.isFilipino() ? 'Deskripsyon' : 'Description',
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
                      _categoriesApi
                          .map<DropdownMenuItem<String>>(
                            (cat) => DropdownMenuItem(
                              value: cat['id'].toString(),
                              child: Text(cat['name']),
                            ),
                          )
                          .toList(),
                  onChanged: (v) => setState(() => _selectedCategory = v),
                  decoration: InputDecoration(
                    labelText: lang.isFilipino() ? 'Kategorya' : 'Category',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                SizedBox(height: 24),
                // Add button with loading indicator
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : submitProduct,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                    ),
                    child:
                        _isSubmitting
                            ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : Text(
                              lang.isFilipino() ? 'Idagdag' : 'Add',
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
      ),
    );
  }
}
