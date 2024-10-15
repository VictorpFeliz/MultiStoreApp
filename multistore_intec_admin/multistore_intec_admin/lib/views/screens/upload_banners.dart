  // ignore_for_file: avoid_print

  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:file_picker/file_picker.dart';
  import 'package:firebase_storage/firebase_storage.dart';
  import 'package:flutter/material.dart';
  import 'package:flutter_easyloading/flutter_easyloading.dart';
  import 'package:shimmer/shimmer.dart';
  import 'package:cached_network_image/cached_network_image.dart';

class UploadBanners extends StatefulWidget {
  static const String id = "UploadBanners";

  @override
  State<UploadBanners> createState() => _UploadBannersState();
}

class _UploadBannersState extends State<UploadBanners> {

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //Variable para almacenar la imagen seleccionada
  dynamic _image;
  //Variable para almacenar la ruta de la imagen
  String? fileName;

  //Metodo para seleccionar una imagen

  _pickImage() async{
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: false, type: FileType.image);

    if(result != null){
      setState(() {
        _image = result.files.first.bytes;
        fileName = result.files.first.name;
      });
    }
  }

  //Metodo para subir imagen al Storage

 Future<String> _uploadBannerToStorage(dynamic image) async {
    var ref = _storage.ref().child('banners').child(fileName!);
    UploadTask uploadTask = ref.putData(image);
    TaskSnapshot snapshot = await uploadTask;
    String downloadURL = await snapshot.ref.getDownloadURL();
    return downloadURL;


  }


  //Metodo para Cargar el URL de la imagen a FireStore
  Future<void> _uploadBannerToFireStore() async{
    if(_image != null){
      EasyLoading.show();
      String imageURL = await _uploadBannerToStorage(_image);
      await _firestore.collection('banners').doc(fileName).set({
        'bannerImage': imageURL,
      }).whenComplete(() {
        EasyLoading.dismiss();
        setState(() {
          _image=null;
        });
      });

    }
    else {
         // Show error if no image is selected
      EasyLoading.showError("Please select an image before saving");
    }
  }



   @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.topLeft,
          padding: const EdgeInsets.all(10),
          child: const Text(
            "Banners",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 36,
            ),
          ),
        ),
        const Divider(
          color: Colors.grey,
        ),
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Container(
                    height: 140,
                    width: 140,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade500,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _image != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.memory(_image, fit: BoxFit.cover),
                          )
                        : const Center(
                            child: Text('Upload Banner...'),
                          ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: const Text("Select Image"),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: _uploadBannerToFireStore,
              child: const Text('Save'),
            ),
          ],
        ),
        Container(
          alignment: Alignment.topLeft,
          padding: const EdgeInsets.all(10),
          child: const Text(
            "Banners",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 36,
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Remover el Expanded y ajustar el StreamBuilder directamente
        StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('banners').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final banners = snapshot.data!.docs;

            return LayoutBuilder(
              builder: (context, constraints) {
                double imageWidth = (constraints.maxWidth / 3) - 10;
                // ignore: unused_local_variable
                double imageHeight = imageWidth * 10 / 16;

                return GridView.builder(
                  padding: const EdgeInsets.all(10),
                  shrinkWrap: true, // Agregar shrinkWrap
                  physics: const NeverScrollableScrollPhysics(), // Deshabilitar el desplazamiento interno
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 16 / 10,
                  ),
                  itemCount: banners.length,
                  itemBuilder: (context, index) {
                    final bannerData =
                        banners[index].data() as Map<String, dynamic>;
                    final bannerUrl = bannerData['bannerImage'];

                    return ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: bannerUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          child: Container(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.broken_image,
                          color: Colors.red,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}