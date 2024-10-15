import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import "package:flutter_application_1/Views/Vendor/landing_screen.dart";
// ignore: unused_import
import 'package:flutter_application_1/Views/Vendor/vendero_main_screen.dart';

class VendorAuthScreen extends StatelessWidget {
  const VendorAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
  stream: FirebaseAuth.instance.authStateChanges(),
  // If the user is already signed-in, use it as initial data
  initialData: FirebaseAuth.instance.currentUser,
  builder: (context, snapshot) {
    // User is not signed in
    if (!snapshot.hasData) {
      return SignInScreen(
        providers: [
          EmailAuthProvider()
        ]
      );
    }

    // Render your application if authenticated
    return LandingScreen();
  },
);
  }
}