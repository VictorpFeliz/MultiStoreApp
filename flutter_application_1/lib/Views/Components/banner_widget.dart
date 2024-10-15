import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class BannerWidget extends StatefulWidget {
  const BannerWidget({super.key});

  @override
  State<BannerWidget> createState() => _BannerWidgetState();
}

class _BannerWidgetState extends State<BannerWidget> {
  List<String> bannerUrls = [];

  @override
  void initState() {
    super.initState();
    _loadBannerUrls();
  }

  Future<void> _loadBannerUrls() async {
    firebase_storage.ListResult result = await firebase_storage.FirebaseStorage.instance
        .ref('banners')  // Carpeta donde están tus imágenes
        .listAll();

    List<String> urls = await Future.wait(result.items.map((firebase_storage.Reference ref) async {
      return await ref.getDownloadURL();
    }));

    setState(() {
      bannerUrls = urls;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (bannerUrls.isEmpty) {
      return const Center(child: Text("No hay banners disponibles"));
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      height: 100,
      width: double.infinity,
      child: PageView.builder(
        itemCount: bannerUrls.length,
        itemBuilder: (context, index) {
          String bannerUrl = bannerUrls[index];
          return ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              bannerUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) {
                return const Center(child: Icon(Icons.error));
              },
            ),
          );
        },
      ),
    );
  }
}
