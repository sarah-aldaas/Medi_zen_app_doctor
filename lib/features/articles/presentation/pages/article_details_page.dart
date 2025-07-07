import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';

import '../../../../base/theme/app_color.dart';
import '../../data/model/article_model.dart';

class ArticleDetailsPage extends StatelessWidget {
  final ArticleModel article;

  const ArticleDetailsPage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'articleDetails.article_details'.tr(context),
          style: TextStyle(
            color: AppColors.primaryColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (article.imageUrl != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    article.imageUrl!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const Gap(16),
              ],
              if (article.category != null) ...[
                Text(
                  "${"articleDetails.content.category".tr(context)}: ${article.category!.display}",
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap(8),
              ],
              Text(
                article.createdAt?.toLocal().toString().split(' ')[0] ?? '',
                style: const TextStyle(color: Colors.grey),
              ),
              const Gap(16),
              Text(
                article.title ?? '',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(16),
              Text(
                article.content ?? '',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (article.doctor != null) ...[
                const Gap(24),
                _buildDoctorInfo(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const Gap(8),
        Text(
          "articleDetails.author".tr(context),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.primaryColor,
          ),
        ),
        const Gap(8),
        Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(article.doctor!.avatar ?? ''),
              radius: 30,
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${article.doctor!.prefix} ${article.doctor!.given} ${article.doctor!.family}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (article.doctor!.clinic != null)
                    Text(
                      article.doctor!.clinic!.name,
                      style: const TextStyle(color: Colors.grey),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
