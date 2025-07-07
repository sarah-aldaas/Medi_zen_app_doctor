import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medi_zen_app_doctor/base/blocs/code_types_bloc/code_types_cubit.dart';
import 'package:medi_zen_app_doctor/base/data/models/code_type_model.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
import 'package:medi_zen_app_doctor/base/widgets/loading_page.dart';
import 'package:medi_zen_app_doctor/base/widgets/show_toast.dart';
import 'package:medi_zen_app_doctor/features/articles/data/model/article_model.dart';
import 'package:medi_zen_app_doctor/features/articles/presentation/cubit/article_cubit/article_cubit.dart';

import '../../../../base/theme/app_color.dart';

class UpdateArticlePage extends StatefulWidget {
  final ArticleModel article;

  const UpdateArticlePage({super.key, required this.article});

  @override
  State<UpdateArticlePage> createState() => _UpdateArticlePageState();
}

class _UpdateArticlePageState extends State<UpdateArticlePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String? _selectedCategoryId;
  File? _imageFile;
  List<CodeModel> _categories = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.article.title ?? '';
    _contentController.text = widget.article.content ?? '';
    _selectedCategoryId = widget.article.category?.id;
    _loadCategories();
  }

  void _loadCategories() async {
    final categories = await context
        .read<CodeTypesCubit>()
        .articleCategoryTypeCodes(context: context);
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
        title: Text(
          "articles.update.title".tr(context),
          style: TextStyle(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<ArticleCubit, ArticleState>(
        listener: (context, state) {
          if (state is ArticleUpdateSuccess) {
            ShowToast.showToastSuccess(
              message: "articles.update.success".tr(context),
            );
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
                const SizedBox(height: 20),
                TextField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    labelText: "articles.add.content".tr(context),
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _selectedCategoryId,
                  decoration: InputDecoration(
                    labelText: "articles.filters.category".tr(context),
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text("articles.filters.allCategories".tr(context)),
                    ),
                    ..._categories.map((category) {
                      return DropdownMenuItem(
                        value: category.id,
                        child: Text(category.display),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCategoryId = value;
                    });
                  },
                ),
                const SizedBox(height: 25),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _pickImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor.withOpacity(0.7),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      elevation: 3,
                    ),
                    icon: const Icon(Icons.image),
                    label: Text("articles.add.uploadImage".tr(context)),
                  ),
                ),
                if (_imageFile != null) ...[
                  const SizedBox(height: 20),
                  Image.file(_imageFile!, height: 100, fit: BoxFit.cover),
                ] else if (widget.article.imageUrl != null) ...[
                  const SizedBox(height: 20),
                  Center(
                    child: Image.network(
                      widget.article.imageUrl!,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
                const SizedBox(height: 25),
                Center(
                  child: ElevatedButton(
                    onPressed:
                        _isSubmitting
                            ? null
                            : () {
                              if (_titleController.text.isEmpty ||
                                  _contentController.text.isEmpty) {
                                ShowToast.showToastError(
                                  message: "articles.add.requiredFields".tr(
                                    context,
                                  ),
                                );
                                return;
                              }
                              setState(() {
                                _isSubmitting = true;
                              });
                              final article = widget.article.copyWith(
                                title: _titleController.text,
                                content: _contentController.text,
                                imageFile: _imageFile,
                                category:
                                    _selectedCategoryId != null
                                        ? _categories.firstWhere(
                                          (c) => c.id == _selectedCategoryId,
                                        )
                                        : null,
                              );
                              context.read<ArticleCubit>().updateArticle(
                                article: article,
                                articleId: widget.article.id!,
                                context: context,
                              );
                            },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor.withOpacity(0.7),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      elevation: 3,
                    ),
                    child: Text("articles.update.submit".tr(context)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
