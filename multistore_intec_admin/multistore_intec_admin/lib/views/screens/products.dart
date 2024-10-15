// ignore_for_file: unused_field, unused_element

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class Products extends StatefulWidget {
      static const String id = "Products";
  @override
  State<Products> createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final TextEditingController productNameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController sizeController = TextEditingController();

  String? selectedCategory;
  String? _productError;
  List<Uint8List> _images = []; // Lista que solo contiene Uint8List no nulos
  List<String> _imageUrls = []; // Lista que contiene URLs de imágenes subidas

  Future<void> _pickImages() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
    );

    if (result != null) {
      setState(() {
        // Filtrar y asignar solo imágenes no nulas
        _images = result.files
            .map((file) => file.bytes)
            .whereType<Uint8List>()
            .toList();
      });
    }
  }

  Future<String> _uploadImageToStorage(Uint8List image, String imageName) async {
    Reference ref = _storage.ref().child('products').child(imageName);
    UploadTask uploadTask = ref.putData(image);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> _uploadProductToFirestore() async {
    // Validar los campos de entrada
    if (productNameController.text.isNotEmpty &&
        priceController.text.isNotEmpty &&
        quantityController.text.isNotEmpty &&
        selectedCategory != null &&
        _images.isNotEmpty) {
      EasyLoading.show();

      // Limpiar la lista de URLs de imágenes antes de subir nuevas
      _imageUrls = [];

      try {
        // Subir imágenes y recopilar sus URLs
        for (var i = 0; i < _images.length; i++) {
          String imageName = '${productNameController.text}_$i';
          String imageUrl = await _uploadImageToStorage(_images[i], imageName);
          _imageUrls.add(imageUrl); // Almacenar URLs de imágenes en la lista
        }

        // Agregar el producto a Firestore
        await _firestore.collection('products').add({
          'productName': productNameController.text,
          'price': double.tryParse(priceController.text) ?? 0,
          'discount': double.tryParse(discountController.text) ?? 0,
          'quantity': int.tryParse(quantityController.text) ?? 1,
          'description': descriptionController.text,
          'category': selectedCategory,
          'size': sizeController.text,
          'images': _imageUrls, // Almacenar URLs de imágenes en Firestore
        }).whenComplete(() {
          EasyLoading.dismiss();
          setState(() {
            // Limpiar el formulario
            productNameController.clear();
            priceController.clear();
            discountController.clear();
            quantityController.clear();
            descriptionController.clear();
            sizeController.clear();
            selectedCategory = null;
            _productError = null;
            _images = []; // Limpiar imágenes seleccionadas
            _imageUrls = []; // Limpiar URLs de imágenes
          });
        });
      } catch (e) {
        EasyLoading.dismiss();
        EasyLoading.showError("Error al subir el producto: $e");
        setState(() {
          _productError = "Ocurrió un error al subir el producto.";
        });
      }
    } else {
      // Mostrar mensaje de error si los campos no están completos correctamente
      setState(() {
        _productError =
            "Please complete all fields and upload at least one image.";
      });
      EasyLoading.showError("Please complete all fields.");
    }
  }

  Widget _buildImagePreview() {
    if (_images.isEmpty) {
      return const SizedBox.shrink(); // Retorna un Widget vacío si no hay imágenes
    }

    return SizedBox(
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _images.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Image.memory(
                    _images[index],
                    fit: BoxFit.cover,
                  ),
                ),
                // Botón para eliminar la imagen en la esquina superior derecha
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(
                      Icons.remove_circle,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      setState(() {
                        _images.removeAt(index);
                      });
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 700,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Product Information'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter Product Information',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 10),
                // Product Name
                TextField(
                  controller: productNameController,
                  decoration: const InputDecoration(
                    labelText: 'Enter Product Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                // Price and Category in a Row
                Row(
                  children: [
                    // Price Field
                    Expanded(
                      child: TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Enter Price',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Category Dropdown
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: _firestore.collection('categories').snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            // Envolver en Center para evitar tamaños infinitos
                            return const Center(child: CircularProgressIndicator());
                          }
                          final categories = snapshot.data!.docs;
      
                          return DropdownButtonFormField<String>(
                            value: selectedCategory,
                            hint: const Text('Select a Category'),
                            items: categories.map((doc) {
                              final categoryName = doc['categoryName'] as String;
                              return DropdownMenuItem<String>(
                                value: categoryName,
                                child: Text(categoryName),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedCategory = value;
                              });
                            },
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Discount Field
                TextField(
                  controller: discountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Discount',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                // Quantity Field
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                // Description Field
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                // Add a Size Field
                TextField(
                  controller: sizeController,
                  decoration: const InputDecoration(
                    labelText: 'Add a Size',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                // Upload Images Section
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _pickImages,
                      child: const Text('Select Images'),
                    ),
                    const SizedBox(width: 10),
                    // Show selected image count
                    Text('${_images.length} image(s) selected'),
                  ],
                ),
                const SizedBox(height: 10),
                // Image Preview Widget
                _buildImagePreview(),
                const SizedBox(height: 20),
                // Add Product Button
                ElevatedButton(
                  onPressed: _uploadProductToFirestore,
                  child: const Text('Add Product'),
                ),
                if (_productError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      _productError!,
                      style: const TextStyle(color: Colors.red),
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
