import 'package:flutter/material.dart';

import '../../../base/constant/app_images.dart';
import '../../../base/theme/app_color.dart';
import '../model/articales_model.dart';

class AddArticaleScreen extends StatefulWidget {
  final Function(Articale) onArticaleAdded;

  const AddArticaleScreen({Key? key, required this.onArticaleAdded})
    : super(key: key);

  @override
  _AddArticaleScreenState createState() => _AddArticaleScreenState();
}

class _AddArticaleScreenState extends State<AddArticaleScreen> {
  final _titleController = TextEditingController();
  final _shortDescriptionController = TextEditingController();
  final _contentController = TextEditingController();
  String? _imageUrl;

  void _addArticle() {
    if (_titleController.text.isNotEmpty &&
        _shortDescriptionController.text.isNotEmpty &&
        _contentController.text.isNotEmpty &&
        _imageUrl != null &&
        _imageUrl!.isNotEmpty) {
      final newArticle = Articale(
        title: _titleController.text,
        shortDescription: _shortDescriptionController.text,
        imageUrl: _imageUrl!,
        content: _contentController.text,
      );
      widget.onArticaleAdded(newArticle);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء ملء جميع الحقول وتحميل صورة.')),
      );
    }
  }

  Future<void> _uploadImage() async {
    setState(() {
      _imageUrl = AppAssetImages.article1; // استخدم صورة افتراضية
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'إضافة مقالة جديدة',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'عنوان المقالة',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _shortDescriptionController,
              decoration: InputDecoration(
                labelText: 'وصف مختصر',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: 'نص المقالة',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              maxLines: 8,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton.icon(
              onPressed: _uploadImage,
              icon: const Icon(Icons.upload_file),
              label: const Text('تحميل صورة', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.greenLightColor,
                foregroundColor: Colors.white,
              ),
            ),
            if (_imageUrl != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: SizedBox(
                  height: 80.0,
                  child: Image.asset(
                    _imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.image_not_supported, size: 48.0);
                    },
                  ),
                ),
              ),
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: _addArticle,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              child: const Text(
                'إضافة المقالة',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _shortDescriptionController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
