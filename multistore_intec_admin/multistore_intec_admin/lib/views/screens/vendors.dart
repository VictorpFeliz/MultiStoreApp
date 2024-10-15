// ignore_for_file: library_private_types_in_public_api, unused_element

import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:multistore_intec_admin/views/widget/header_widget.dart';
import 'package:multistore_intec_admin/views/widget/vendor_widget.dart';

class Vendors extends StatefulWidget {
  static const String id = "Vendors";

  @override
  _Vendors createState() => _Vendors();
}

class _Vendors extends State<Vendors> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> vendors = [];
  Uint8List? _selectedImageBytes;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadVendors();
    });
  }

  // Fetch the list of vendors from Firestore
  Future<void> _loadVendors() async {
    try {
      EasyLoading.show(status: 'Loading vendors...');
      final QuerySnapshot vendorSnapshot =
          await _firestore.collection('vendors').get();
      setState(() {
        vendors = vendorSnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
      EasyLoading.dismiss();
    } catch (e) {
      EasyLoading.showError('Error loading vendors: $e');
    }
  }

  // Approve a vendor by updating the "approved" status in Firestore
  Future<void> _approveVendor(String vendorId, bool approve) async {
    try {
      EasyLoading.show(
          status: approve ? 'Approving vendor...' : 'Disapproving vendor...');
      await _firestore.collection('vendors').doc(vendorId).update({
        'approved': approve,
      });
      EasyLoading.dismiss();
      _loadVendors(); // Refresh the vendor list
    } catch (e) {
      EasyLoading.showError('Failed to update vendor: $e');
    }
  }

  // Modify vendor details
  Future<void> _modifyVendor(
      String vendorId, Map<String, dynamic> updatedData) async {
    try {
      EasyLoading.show(status: 'Updating vendor...');
      await _firestore.collection('vendors').doc(vendorId).update(updatedData);
      EasyLoading.dismiss();
      _loadVendors(); // Refresh vendor list
    } catch (e) {
      EasyLoading.showError('Failed to update vendor: $e');
    }
  }

  // Delete vendor
  Future<void> _deleteVendor(String vendorId) async {
    try {
      EasyLoading.show(status: 'Deleting vendor...');
      await _firestore.collection('vendors').doc(vendorId).delete();
      EasyLoading.dismiss();
      _loadVendors(); // Refresh the vendor list
    } catch (e) {
      EasyLoading.showError('Failed to delete vendor: $e');
    }
  }

  // Upload image to Firebase Storage and get the download URL
  Future<String?> _uploadImage(Uint8List imageBytes) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('vendor_images')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putData(imageBytes);
      return await ref.getDownloadURL();
    } catch (e) {
      EasyLoading.showError('Failed to upload image: $e');
      return null;
    }
  }

  // Show the modify vendor dialog
  void _showModifyVendorDialog(Map<String, dynamic> vendor) {
    TextEditingController businessNameController =
        TextEditingController(text: vendor['businessName']);
    TextEditingController emailController =
        TextEditingController(text: vendor['email']);
    TextEditingController phoneController =
        TextEditingController(text: vendor['phoneNumber']);
    TextEditingController cityController =
        TextEditingController(text: vendor['city']);
    TextEditingController stateController =
        TextEditingController(text: vendor['state']);
    TextEditingController countryController =
        TextEditingController(text: vendor['country']);
    TextEditingController rncController =
        TextEditingController(text: vendor['rnc']);
    TextEditingController taxController =
        TextEditingController(text: vendor['tax']);

    _selectedImageBytes = null; // Reset the selected image each time

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Modify Vendor Details'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Image Picker
                    GestureDetector(
                      onTap: () async {
                        FilePickerResult? result =
                            await FilePicker.platform.pickFiles(
                          type: FileType.image,
                        );
                        if (result != null) {
                          setState(() {
                            _selectedImageBytes = result.files.single.bytes;
                          });
                        }
                      },
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.grey[400]!,
                          ),
                        ),
                        child: _selectedImageBytes != null
                            ? Image.memory(
                                _selectedImageBytes!,
                                fit: BoxFit.cover,
                              )
                            : vendor['imageUrl'] != ''
                                ? CachedNetworkImage(
                                    imageUrl: vendor['imageUrl'],
                                    fit: BoxFit.cover,
                                  )
                                : const Center(
                                    child: Icon(
                                      Icons.add_a_photo,
                                      color: Colors.grey,
                                      size: 40,
                                    ),
                                  ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: businessNameController,
                      decoration: const InputDecoration(
                        labelText: 'Business Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: cityController,
                      decoration: const InputDecoration(
                        labelText: 'City',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: stateController,
                      decoration: const InputDecoration(
                        labelText: 'State',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: countryController,
                      decoration: const InputDecoration(
                        labelText: 'Country',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: rncController,
                      decoration: const InputDecoration(
                        labelText: 'RNC',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: taxController,
                      decoration: const InputDecoration(
                        labelText: 'Tax',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    String? imageUrl = vendor['imageUrl'];

                    if (_selectedImageBytes != null) {
                      // Upload the selected image
                      imageUrl = await _uploadImage(_selectedImageBytes!);
                    }

                    // Save modified details to Firestore
                    final updatedData = {
                      'businessName': businessNameController.text,
                      'email': emailController.text,
                      'phoneNumber': phoneController.text,
                      'city': cityController.text,
                      'state': stateController.text,
                      'country': countryController.text,
                      'rnc': rncController.text,
                      'tax': taxController.text,
                      'imageUrl': imageUrl,
                    };
                    _modifyVendor(vendor['vendorId'], updatedData);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

   @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.all(10),
            child: const Text(
              'Manage Vendors',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 36,
              ),
            ),
          ),
          Row(
            children: [
              HeaderWidget.rowHeader('LOGO', 1),
              HeaderWidget.rowHeader('BUSINESS NAME', 3),
              HeaderWidget.rowHeader('CITY', 2),
              HeaderWidget.rowHeader('STATE', 2),
              HeaderWidget.rowHeader('ACTION', 1),
              HeaderWidget.rowHeader('VIEW MORE', 1),
            ],
          ),
          VendorWidget(),
        ],
      ),
    );
  }
}


