import 'package:flutter/material.dart';


class Button extends StatelessWidget {

  final Function()? onTap;

  const Button({super.key, required this.onTap, required String text});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(25),
        margin: const EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: Text("Sign In",
          style: TextStyle(color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
          ),),
        ),
      ),
    );
  }
}