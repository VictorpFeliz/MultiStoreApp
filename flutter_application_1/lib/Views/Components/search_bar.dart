import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  const SearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.16,
      child: Stack(
        children: [
          Image.asset('assets/icons/searchBanner.jpeg',
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
          ),
          Positioned(
            left: 48,
            top: 68,
            child: SizedBox(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Look something...',
                  hintStyle: const TextStyle(
                    color: Color(0xff7f7f7f),
                    fontSize: 14
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  fillColor: Colors.grey.shade200,
                  filled: true,
                ),
              ),
            ),
          ),
          Positioned(
            left: 311,
            top: 60,
            child: InkWell(
              onTap: () {

              },
              child: Image.asset('assets/icons.search.png',
            width: 70, height: 70,
            color: Colors.white
              ),
            ),
            ),
            
        ],
      ),
    );
  }
}