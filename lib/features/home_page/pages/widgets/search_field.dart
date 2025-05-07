import 'package:flutter/material.dart';

class SearchField extends StatelessWidget {
  SearchField({super.key});

  final TextEditingController _searchController = TextEditingController();
  final double _opacityLevel = 0.6; // Adjust this value for desired opacity

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          filled: true, // Enable filling the background color
          fillColor: Colors.grey.shade50, // Set the background color
          hintText: 'Search...',
          hintStyle: TextStyle(color: Colors.grey.withOpacity(_opacityLevel)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(color: Colors.transparent),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(color: Theme.of(context).primaryColor),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey.withOpacity(_opacityLevel),
          ),
        ),
      ),
    );
  }
}