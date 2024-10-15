// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter_application_1/Views/Components/banner_widget.dart';
import 'package:flutter_application_1/Views/Components/category_widget.dart';
import 'package:flutter_application_1/Views/Components/products_widget.dart';
import 'package:flutter_application_1/Views/Components/top_bar.dart';
import 'package:flutter_application_1/Models/product_model.dart';
import 'package:flutter_application_1/Views/screens/product_details_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
String? selectedCategory;






// ignore: unused_element
void _onCategorySelected(String? category) {
    setState(() {
      selectedCategory = category; // Update the selected category
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(55.0),
        child: TopBar(),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            const BannerWidget(),
            const SizedBox(height: 10),
            CategoryWidget(onCategorySelected: _onCategorySelected),
            const SizedBox(height: 20),
            ProductsWidget(selectedCategory: selectedCategory), // Filter products
          ],
        ),
      ),
    );
  }
}