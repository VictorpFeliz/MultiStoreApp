// ignore_for_file: unused_import

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:multistore_intec_admin/views/screens/Buyers.dart';
import 'package:multistore_intec_admin/views/screens/Orders.dart';
import 'package:multistore_intec_admin/views/screens/vendors.dart';
import 'package:multistore_intec_admin/views/screens/categories.dart';
import 'package:multistore_intec_admin/views/screens/products.dart';
import 'package:multistore_intec_admin/views/screens/upload_banners.dart';

class MainScreen extends StatefulWidget {
  static const String id = "MainScreen";

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  Widget _selectedScreen = Vendors();
  currentScreen(item){
    switch(item.route){
      case Buyers.id :
      setState(() {
       _selectedScreen = Buyers(); 
      });
      break;

      case Categories.id :
      setState(() {
       _selectedScreen = Categories(); 
      });
      break;

      case Orders.id :
      setState(() {
       _selectedScreen = Orders(); 
      });
      break;

      case Products.id :
      setState(() {
       _selectedScreen = Products(); 
      });
      break;

      case UploadBanners.id :
      setState(() {
       _selectedScreen = UploadBanners(); 
      });
      break;

      case Vendors.id :
      setState(() {
       _selectedScreen = Vendors(); 
      });
      break;
    }
  }

  @override
Widget build(BuildContext context) {
  return AdminScaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      title: const Center(child: Text('Multivendor Admin Panel')),
    ),
    sideBar: SideBar(
      items: const [
        AdminMenuItem(title: 'Vendors', route: Vendors.id, icon: Icons.people),
        AdminMenuItem(title: 'Buyers', icon: Icons.person, route: Buyers.id),
        AdminMenuItem(title: 'Orders', icon: Icons.shopping_cart, route: Orders.id),
        AdminMenuItem(title: 'Categories', icon: Icons.category, route: Categories.id),
        AdminMenuItem(title: 'UploadBanners', icon: Icons.add, route: UploadBanners.id),
        AdminMenuItem(title: 'Products', icon: Icons.shopping_bag, route: Products.id),
      ],
      selectedRoute: MainScreen.id,
      onSelected: (item) {
        currentScreen(item);
      },
    ),
    body: SizedBox(
      width: double.infinity, // o un tamaño específico
      child: _selectedScreen,
    ),
  );
}

}