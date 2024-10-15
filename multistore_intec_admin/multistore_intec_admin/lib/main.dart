import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:multistore_intec_admin/views/screens/Buyers.dart';
import 'package:multistore_intec_admin/views/screens/Orders.dart';
import 'package:multistore_intec_admin/views/screens/vendors.dart';
import 'package:multistore_intec_admin/views/screens/main_screen.dart';
import 'package:multistore_intec_admin/views/screens/products.dart';
import 'package:multistore_intec_admin/views/screens/splash_screen.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:multistore_intec_admin/views/screens/upload_banners.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
            apiKey: "AIzaSyBP-lny0I-rxsttfPTLHpQDnSCYfT73BuI", 
      appId: "1:104855549115:web:b42023112cdbab43f0659e", 
      messagingSenderId: "104855549115", 
      projectId: "multistore-store-intec", 
      storageBucket: "multistore-store-intec.appspot.com")
  );
  runApp(const MyApp());
  configLoading();
}

void configLoading() {
  EasyLoading.instance
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..maskType = EasyLoadingMaskType.black;
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp( 
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: MainScreen.id,
      routes: { 
        MainScreen.id :(context) => MainScreen(),
        SplashScreen.id :(context) => SplashScreen(),
        Buyers.id :(context) => Buyers(),
        Orders.id :(context) => Orders(),
        Products.id :(context) => Products(),
        Vendors.id :(context) => Vendors(),
        UploadBanners.id :(context) => UploadBanners(),
      }
    );
  }
}
