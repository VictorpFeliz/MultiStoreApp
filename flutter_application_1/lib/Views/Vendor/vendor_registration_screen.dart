// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class VendorRegistrationScreen extends StatefulWidget {
  const VendorRegistrationScreen({super.key});

  @override
  _VendorRegistrationScreenState createState() =>
      _VendorRegistrationScreenState();
}

class _VendorRegistrationScreenState extends State<VendorRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  // Controladores de los campos del formulario
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _rncController = TextEditingController();
  final TextEditingController _taxController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  File? _selectedImage; // Variable para almacenar la imagen seleccionada
  bool _isUploading = false; // Estado de subida

  // Función para seleccionar una imagen desde la galería
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Función para subir la imagen a Firebase Storage y obtener la URL
  Future<String?> _uploadImage(File imageFile) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef = _firebaseStorage.ref().child('vendor_images/$fileName');
      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al subir la imagen: $e')),
      );
      return null;
    }
  }

  // Función para enviar los detalles del vendedor
  Future<void> _submitVendorDetails() async {
  if (_formKey.currentState!.validate()) {
    if (!mounted) return;
    
    setState(() {
      _isUploading = true;
    });

    try {
      // Subir la imagen si fue seleccionada
      String imageUrl = '';
      if (_selectedImage != null) {
        String? uploadedImageUrl = await _uploadImage(_selectedImage!);
        if (uploadedImageUrl != null) {
          imageUrl = uploadedImageUrl;
        } else {
          if (mounted) {
            setState(() {
              _isUploading = false;
            });
          }
          return;
        }
      }

      // Obtener el UID del usuario actual
      String uid = _firebaseAuth.currentUser!.uid;

      // Crear los datos del vendedor
      Map<String, dynamic> vendorData = {
        'vendorId': uid,
        'approved': false,
        'businessName': _businessNameController.text,
        'city': _cityController.text,
        'country': _countryController.text,
        'email': _firebaseAuth.currentUser!.email ?? _emailController.text,
        'image': imageUrl,
        'phoneNumber': _phoneNumberController.text,
        'rnc': _rncController.text,
        'tax': _taxController.text,
      };

      // Guardar los datos en Firestore
      await _firebaseFirestore.collection('vendors').doc(uid).set(vendorData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Detalles del vendedor enviados exitosamente')),
        );
      }

      // Opcional: Navegar a la pantalla principal después del registro
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const VenderoMainScreen()));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registro de Vendedor"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Encabezado
                const Text(
                  'Registra tu Negocio',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Selector de imagen
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[200],
                    ),
                    child: _selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(
                            Icons.camera_alt,
                            size: 50,
                            color: Colors.grey,
                          ),
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Selecciona una imagen de tu negocio',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Campo de Nombre del Negocio
                TextFormField(
                  controller: _businessNameController,
                  decoration: InputDecoration(
                    labelText: 'Nombre del Negocio',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.business),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa el nombre de tu negocio';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // Campo de Ciudad
                TextFormField(
                  controller: _cityController,
                  decoration: InputDecoration(
                    labelText: 'Ciudad',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.location_city),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa tu ciudad';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // Campo de País
                TextFormField(
                  controller: _countryController,
                  decoration: InputDecoration(
                    labelText: 'País',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.flag),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa tu país';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // Campo de Email (prellenado y deshabilitado)
                TextFormField(
  controller: _emailController,
  decoration: InputDecoration(
    labelText: 'Email',
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    prefixIcon: const Icon(Icons.email),
  ),
  keyboardType: TextInputType.emailAddress,
  enabled: true, // Deshabilitar edición si usas el email de Firebase Auth
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, ingresa tu email';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Por favor, ingresa un email válido';
    }
    return null;
  },
),
                const SizedBox(height: 15),

                // Campo de Número de Teléfono
                TextFormField(
                  controller: _phoneNumberController,
                  decoration: InputDecoration(
                    labelText: 'Número de Teléfono',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa tu número de teléfono';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // Campo de RNC
                TextFormField(
                  controller: _rncController,
                  decoration: InputDecoration(
                    labelText: 'RNC',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.account_balance),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa tu RNC';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // Campo de Número de Impuestos
                TextFormField(
                  controller: _taxController,
                  decoration: InputDecoration(
                    labelText: 'Número de Impuestos',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.attach_money),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa tu número de impuestos';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                // Botón de Envío
                ElevatedButton(
                  onPressed: _isUploading ? null : _submitVendorDetails,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.teal,
                  ),
                  child: _isUploading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Enviar',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
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
