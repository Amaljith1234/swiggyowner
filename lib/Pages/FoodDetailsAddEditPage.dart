import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:swiggyowner/Utils/Network_Utils.dart';
import '../Utils/AppUtils.dart';

class AddEditItemPage extends StatefulWidget {
  final String? id;
  final Map<String, dynamic>? existingData;

  const AddEditItemPage({this.id, this.existingData});

  @override
  _AddEditItemPageState createState() => _AddEditItemPageState();
}

class _AddEditItemPageState extends State<AddEditItemPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  bool _available = true;
  List<XFile> _selectedImages = [];
  List<String> _existingImages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingData != null) {
      _nameController.text = widget.existingData!['name'] ?? '';
      _descriptionController.text = widget.existingData!['description'] ?? '';
      _priceController.text = widget.existingData!['price']?.toString() ?? '';
      _categoryController.text = widget.existingData!['category'] ?? '';
      _available = widget.existingData!['available'] ?? true;
      _existingImages = List<String>.from(widget.existingData!['images'] ?? []);
    }
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? images = await picker.pickMultiImage();
    if (images != null) {
      setState(() => _selectedImages.addAll(images));
    }
  }

  // ✅ Remove newly selected image
  void _removeSelectedImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  // ✅ Remove existing image
  void _removeExistingImage(int index) {
    setState(() {
      _existingImages.removeAt(index);
    });
  }

  Future<void> _submitData() async {
    if (_nameController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _categoryController.text.isEmpty) {
      AppUtil.showToast(context, "All fields are required.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? token = await AppUtil.getToken();

      var url = Uri.parse(
          widget.id == null
              ? '${NetworkUtil.base_url}${NetworkUtil.ADD_FOOD_ITEM_URL}'
              : '${NetworkUtil.base_url}${NetworkUtil.UPDATE_FOOD_ITEM_URL}'
      );

      var request = http.MultipartRequest("POST", url);

      request.headers.addAll({
        "Authorization": "Bearer $token",
        "Content-Type": "multipart/form-data",
      });

      // Add form fields
      if (widget.id != null) request.fields['foodId'] = widget.id!;
      request.fields['name'] = _nameController.text;
      request.fields['description'] = _descriptionController.text;
      request.fields['price'] = _priceController.text;
      request.fields['category'] = _categoryController.text;
      request.fields['available'] = _available.toString();

      // Add new images
      for (XFile image in _selectedImages) {
        request.files.add(
          await http.MultipartFile.fromPath('foodImage', image.path),
        );
      }

      // Add remaining existing images
      if (widget.id != null && _existingImages.isNotEmpty) {
        for (int i = 0; i < _existingImages.length; i++) {
          request.fields['existingImages[$i]'] = _existingImages[i];
        }
      }

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        var result = json.decode(responseBody);
        AppUtil.showToast(context, result['message'] ?? "Success!");

        if (widget.id != null) {
          setState(() {
            var data = result['data'];
            _nameController.text = data['name'] ?? _nameController.text;
            _descriptionController.text = data['description'] ?? _descriptionController.text;
            _priceController.text = data['price']?.toString() ?? _priceController.text;
            _categoryController.text = data['category'] ?? _categoryController.text;
            _available = data['available'] ?? _available;
            _existingImages = List<String>.from(data['images'] ?? []);
            _selectedImages.clear();
          });

          Navigator.pop(context, true);
        }
      } else {
        AppUtil.showToast(context, "Failed. Status: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      AppUtil.showToast(context, "Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text(widget.id == null ? 'Add Item' : 'Edit Item')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Price'),
            ),
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Available'),
                Switch(
                  value: _available,
                  onChanged: (value) => setState(() => _available = value),
                ),
              ],
            ),
            const SizedBox(height: 10),

            ElevatedButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.image),
              label: const Text('Select Images'),
            ),

            const SizedBox(height: 10),

            // ✅ Display images with remove buttons
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1,
              ),
              itemCount: _existingImages.length + _selectedImages.length,
              itemBuilder: (context, index) {
                if (index < _existingImages.length) {
                  return Stack(
                    children: [
                      Image.network(
                        _existingImages[index],
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeExistingImage(index),
                          child: const Icon(Icons.remove_circle, color: Colors.red, size: 28),
                        ),
                      ),
                    ],
                  );
                } else {
                  final newIndex = index - _existingImages.length;
                  return Stack(
                    children: [
                      Image.file(
                        File(_selectedImages[newIndex].path),
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeSelectedImage(newIndex),
                          child: const Icon(Icons.highlight_remove_outlined, color: Colors.red, size: 28),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitData,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
