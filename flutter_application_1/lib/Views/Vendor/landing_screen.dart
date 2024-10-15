import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Models/vendor_model.dart';
import 'package:flutter_application_1/Views/Vendor/vendero_main_screen.dart';
import 'package:flutter_application_1/Views/Vendor/vendor_registration_screen.dart';

class LandingScreen extends StatelessWidget {
  LandingScreen({super.key});

final CollectionReference _vendorStream = FirebaseFirestore.instance.collection("vendors");


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(stream: _vendorStream.doc(FirebaseAuth.instance.currentUser!.uid).snapshots(), 
      builder: (context, snapshot) {
        if(snapshot.hasError){
          return const Text("Something went wrong");
        }
        if(snapshot.connectionState == ConnectionState.waiting)
        {
          return const Text('Loading');
        }
         //si el vendedor ha completado todos los campos de registro
        if(!snapshot.data!.exists)
        {
          //Si no hay datos
          return const VendorRegistrationScreen();
        }
        //Traemos los datos del vendedor
        VendorModel vendor = VendorModel.fromJson(
          snapshot.data!.data() as Map<String, dynamic>
          );
          //Esta aprovado el vendedor?
          if(vendor.approved)
          {
            return MainVendorScreen();
          }
          return Column(
            children: [ 
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Image.network(vendor.image,
                width: 90,
                fit: BoxFit.cover,),
              ),
              const SizedBox(
                height: 20,
                ),
                Text(vendor.businessName),
                const SizedBox(
                  height: 10,
                ),
                const Text('Your application has been submitted'),
                TextButton(onPressed: () async{
                  await FirebaseAuth.instance.signOut();
                }, child: const Text('Sign Out'))
            ],
          );
      },
     
      ),
    );
  }
}