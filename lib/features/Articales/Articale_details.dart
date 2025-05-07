import 'package:flutter/material.dart';

import '../../base/theme/app_color.dart';
import '../../base/theme/app_style.dart';
import 'model/articales_model.dart';

class ArticaleDetailsScreen extends StatelessWidget {
  final Articale articale;

  const ArticaleDetailsScreen({Key? key, required this.articale})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(articale.title, style: AppStyles.titleStyle),
        backgroundColor: AppColors.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              articale.imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.image_not_supported,
                  size: 120.0,
                  color: Colors.grey,
                );
              },
            ),
            const SizedBox(height: 20.0),
            Text(
              articale.title,
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10.0),
            Text(
              articale.shortDescription,
              style: const TextStyle(fontSize: 16.0, color: Colors.black87),
            ),
            const SizedBox(height: 20.0),
            Text(
              articale.content,
              style: const TextStyle(fontSize: 16.0, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
