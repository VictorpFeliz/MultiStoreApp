import 'package:flutter/material.dart';
import 'package:flutter_application_1/Views/screens/account_screen.dart';
import 'package:flutter_application_1/Views/screens/cart_screen.dart';
import 'package:flutter_application_1/Views/screens/favorite_screen.dart';
import 'package:flutter_application_1/Views/screens/home_screen.dart';
import 'package:flutter_application_1/Views/screens/store_screen.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {

  int currentPage = 0;

    final List<Widget> _pages = [
    const HomeScreen(),
    const FavoriteScreen(),
    const StoreScreen(),
    const CartScreen(),
    const AccountScreen()
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: currentPage,
        onTap: (value) {
          setState(() {
            currentPage = value;
          });
        },
        items: [
          BottomNavigationBarItem(
              icon: Image.asset('assets/icons/home.png', width: 25,),
              label: 'HOME'),
          BottomNavigationBarItem(
              icon: Image.asset('assets/icons/love.png', width: 25,),
              label: 'FAVORITES'),
          BottomNavigationBarItem(
              icon: Image.asset('assets/icons/mart.png', width: 25,),
              label: 'STORES'),
          BottomNavigationBarItem(
              icon: Image.asset('assets/icons/cart.png', width: 25,),
              label: 'CART'),
          BottomNavigationBarItem(
              icon: Image.asset('assets/icons/cart.png', width: 25,),
              label: 'ACCOUNT'),
        ],
      ),
      body: _pages[currentPage],
    );
  }
}