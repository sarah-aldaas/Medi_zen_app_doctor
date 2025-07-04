import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
import 'package:medi_zen_app_doctor/base/blocs/code_types_bloc/code_types_cubit.dart';
import 'package:medi_zen_app_doctor/base/data/models/code_type_model.dart';
import 'package:medi_zen_app_doctor/base/widgets/loading_page.dart';
import 'package:medi_zen_app_doctor/base/widgets/show_toast.dart';
import 'package:medi_zen_app_doctor/features/articles/data/model/article_model.dart';
import 'package:medi_zen_app_doctor/features/articles/presentation/cubit/article_cubit/article_cubit.dart';

class AddArticlePage extends StatefulWidget {
  const AddArticlePage({super.key});

  @override
  State<AddArticlePage> createState() => _AddArticlePageState();
}

class _AddArticlePageState extends State<AddArticlePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String? _selectedCategoryId;
  File? _imageFile;
  List<CodeModel> _categories = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() async {
    final categories = await context.read<CodeTypesCubit>().articleCategoryTypeCodes(context: context);
    setState(() {
      _categories = categories;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("articles.add.title".tr(context)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<ArticleCubit, ArticleState>(
        listener: (context, state) {
          if (state is ArticleCreateSuccess) {
            ShowToast.showToastSuccess(message: "articles.add.success".tr(context));
            Navigator.pop(context);
          } else if (state is ArticleError) {
            ShowToast.showToastError(message: state.error);
            setState(() {
              _isSubmitting = false;
            });
          }
        },
        builder: (context, state) {
          if (state is ArticleLoading && _isSubmitting) {
            return const Center(child: LoadingPage());
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: "articles.add.title".tr(context),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    labelText: "articles.add.content".tr(context),
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCategoryId,
                  decoration: InputDecoration(
                    labelText: "articles.filters.category".tr(context),
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(value: null, child: Text("articles.filters.allCategories".tr(context))),
                    ..._categories.map((category) {
                      return DropdownMenuItem(value: category.id, child: Text(category.display));
                    }).toList(),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCategoryId = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image),
                  label: Text("articles.add.uploadImage".tr(context)),
                ),
                if (_imageFile != null) ...[
                  const SizedBox(height: 16),
                  Image.file(_imageFile!, height: 100, fit: BoxFit.cover),
                ],
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isSubmitting
                      ? null
                      : () {
                    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
                      ShowToast.showToastError(message: "articles.add.requiredFields".tr(context));
                      return;
                    }
                    setState(() {
                      _isSubmitting = true;
                    });
                    final article = ArticleModel(
                      title: _titleController.text,
                      content: _contentController.text,
                      imageFile: _imageFile,
                      category: _selectedCategoryId != null
                          ? _categories.firstWhere((c) => c.id == _selectedCategoryId)
                          : null,
                    );
                    context.read<ArticleCubit>().createArticle(article: article, context: context);
                  },
                  child: Text("articles.add.submit".tr(context)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  bool _isArabic(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'ar';
  }
}