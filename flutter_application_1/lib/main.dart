// ignore_for_file: unused_import

import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Views/screens/authentication_screens/login_screen1.dart';
import 'package:flutter_application_1/Views/screens/authentication_screens/register_screen.dart';
import 'package:flutter_application_1/Views/screens/main_screen.dart';
import 'package:flutter_application_1/Views/screens/startup_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Platform.isAndroid
  ? await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBiJ_Dgkp4W58hs9myeHwGcqoc5eK9TCJA", 
      appId: "1:104855549115:android:991cf5fc2557dddff0659e", 
      messagingSenderId: "104855549115", 
      projectId: "multistore-store-intec", 
      storageBucket: "multistore-store-intec.appspot.com")
      ) 
      :await Firebase.initializeApp();
  await Firebase.initializeApp();
  runApp(const MyApp());
}
// ignore: use_key_in_widget_constructors
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  const MaterialApp(
      title: 'First Try',
      home: StartupScreen(), 
    );
  }
} 

