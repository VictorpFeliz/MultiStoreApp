import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:multistore_intec_admin/Controller/category_controller.dart';
import 'package:multistore_intec_admin/Models/category_model.dart';
import 'package:google_fonts/google_fonts.dart';

class Categories extends StatefulWidget {
  static const String id = "Categories";

  @override
  State<Categories> createState() => CategoriesState();
}

class CategoriesState extends State<Categories> {
  final CategoryController _categoryController = CategoryController();
  final TextEditingController categoryNameController = TextEditingController();
  String? _categoryError; // Error message holder
  Uint8List? _image;
  String? _fileName;
  List<CategoryModel> categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    _categoryController.getCategories().listen((categoryList) {
      setState(() {
        categories = categoryList;
      });
    });
  }

  void _pickImage(StateSetter setState) async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(allowMultiple: false, type: FileType.image);

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _image = result.files.first.bytes;
        _fileName = result.files.first.name;
      });
    }
  }

  Future<void> _saveCategory() async {
  if (_image != null && categoryNameController.text.isNotEmpty) {
    try {
      print("Saving category started");  // Primer mensaje de depuración
      EasyLoading.show(status: 'Saving...');

      // Cargar la imagen
      print("Uploading image...");
      String imageUrl = await _categoryController.uploadCategoryImage(_image!, _fileName!);
      print("Image uploaded, URL: $imageUrl");

      // Crear la categoría
      CategoryModel category = CategoryModel(
        id: '', // El ID lo genera Firestore
        categoryName: categoryNameController.text,
        categoryImage: imageUrl,
      );

      print("Adding category to Firestore...");
      await _categoryController.addCategory(category);
      print("Category added");

      // Restablecer estado
      setState(() {
        _image = null;
        categoryNameController.clear();
        _categoryError = null; // Limpiar el error
      });

      EasyLoading.dismiss();
      print("Category saved successfully");
    } catch (e) {
      print("Error occurred: $e");
      // En caso de error
      EasyLoading.dismiss();
      EasyLoading.showError("Error saving category: $e");
    }
  } else {
    setState(() {
      _categoryError = categoryNameController.text.isEmpty
          ? "Please enter a category name"
          : null;
    });
    EasyLoading.showError("Please select an image and enter a category name");
  }
}


  Future<void> _deleteCategory(String categoryId) async {
    await _categoryController.deleteCategory(categoryId);
    _loadCategories();
  }

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Add New Category', style: GoogleFonts.lato()),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(
                            _image!,
                            height: 140,
                            width: 140,
                            fit: BoxFit.cover,
                          ),
                        )
                      : GestureDetector(
                          onTap: () {
                            _pickImage(setState);
                          },
                          child: Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade400),
                            ),
                            child: Center(
                              child: Icon(Icons.image,
                                  size: 50, color: Colors.grey.shade500),
                            ),
                          ),
                        ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: categoryNameController,
                    decoration: InputDecoration(
                      labelText: 'Category Name',
                      labelStyle: GoogleFonts.lato(),
                      border: const OutlineInputBorder(),
                      errorText: _categoryError,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      _pickImage(setState);
                    },
                    child: Text('Select Icon', style: GoogleFonts.lato()),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      _saveCategory();
                      Navigator.of(context).pop();
                    },
                    child: Text('Save category', style: GoogleFonts.lato()),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 700,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Manage Categories', style: GoogleFonts.lato()),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton(
                onPressed: _showAddCategoryDialog,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add),
                    const SizedBox(width: 5),
                    Text('New Category', style: GoogleFonts.lato()),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Categories',
                style: GoogleFonts.lato(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
      
                    return Container (
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      child: ListTile(
                        leading: CachedNetworkImage(
                          imageUrl: category.categoryImage,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                        title: Text(category.categoryName, style: GoogleFonts.lato()),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteCategory(category.id),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}