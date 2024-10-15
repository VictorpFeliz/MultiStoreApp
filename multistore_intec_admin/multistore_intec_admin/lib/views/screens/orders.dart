import 'package:flutter/material.dart';

class Orders extends StatelessWidget {
  static const String id = "Orders";

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Orders Screen", 
      style: TextStyle(fontSize: 30, color: Colors.blue),
      ),
    );
  }
}