// ignore: unused_import
import 'package:flutter/material.dart';

class VendorModel {


  VendorModel({
    required this.vendorId,
    required this.approved,
    required this.businessName,
    required this.city,
    required this.country,
    required this.email,
    required this.image,
    required this.phoneNumber,
    required this.rnc,
    required this.tax
  })
;  String vendorId;
  bool approved;
  String businessName;
  String city;
  String country;
  String email;
  String image;
  String phoneNumber;
  String rnc;
  String tax;


factory VendorModel.fromJson(Map<String, dynamic> json) => VendorModel(
  vendorId: json['vendorId'], 
  approved: json['approved'],
   businessName: json['businessName'], 
   city: json['city'], 
   country: json['country'], 
   email: json['email'],
    image: json['image'], 
    phoneNumber: json['phoneNumber'], 
    rnc: json['rnc'], 
    tax: json['tax']
    );
}