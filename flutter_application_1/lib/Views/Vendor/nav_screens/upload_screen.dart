import 'package:flutter/material.dart';
import 'package:flutter_application_1/Views/Vendor/tab_screens/attributes_screen.dart';
import 'package:flutter_application_1/Views/Vendor/tab_screens/general_screen.dart';
import 'package:flutter_application_1/Views/Vendor/tab_screens/images_screen.dart';
import 'package:flutter_application_1/Views/Vendor/tab_screens/shipping_screen.dart';

class UploadScreen extends StatelessWidget {
  const UploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          bottom: const TabBar(
            tabs: [
              Tab(
                child: Text('General'),
              ),
              Tab(
                child: Text('Shipping'),
              ),
              Tab(
                child: Text('Attributes'),
              ),
              Tab(
                child: Text('Images'),
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            GeneralScreen(),
            ShippingScreen(),
            AttributesScreen(),
            ImagesScreen()
          ],
        ),
      ),
    );
  }
}
