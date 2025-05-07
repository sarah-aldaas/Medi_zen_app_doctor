import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medi_zen_app_doctor/features/Articales/pages/Add_Articale.dart';

import '../../base/theme/app_color.dart';
import '../../base/theme/app_style.dart';
import 'Articale_details.dart';
import 'cubit/articales_cubit.dart';
import 'cubit/articales_state.dart';
import 'model/articales_model.dart';

class ArticaleListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ArticaleCubit(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('آخر المقالات', style: AppStyles.titleStyle),
          backgroundColor: AppColors.primaryColor,
        ),
        body: BlocBuilder<ArticaleCubit, ArticaleState>(
          builder: (context, state) {
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: state.articales.length,
              itemBuilder: (context, index) {
                final article = state.articales[index];
                return _buildArticaleItem(context, article);
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _navigateToAddArticaleScreen(context);
          },
          child: const Icon(Icons.add, color: AppColors.whiteColor),
          backgroundColor: AppColors.primaryColor,
        ),
      ),
    );
  }

  void _navigateToAddArticaleScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => AddArticaleScreen(
              onArticaleAdded: (newArticale) {
                context.read<ArticaleCubit>().addArticale(newArticale);
              },
            ),
      ),
    );
  }

  Widget _buildArticaleItem(BuildContext context, Articale article) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: () {
          _showArticaleDetails(context, article);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 100.0,
                height: 100.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.asset(
                    article.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.image_not_supported,
                        size: 48.0,
                        color: Colors.grey,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      article.shortDescription,
                      style: const TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12.0),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showArticaleDetails(BuildContext context, Articale articale) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArticaleDetailsScreen(articale: articale),
      ),
    );
  }
}
