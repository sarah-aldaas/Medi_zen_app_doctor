import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
import 'package:medi_zen_app_doctor/features/articles/presentation/pages/articles_content_page.dart';

import '../../../../base/go_router/go_router.dart';
import '../../../../base/theme/app_color.dart';

class ArticlesTabPage extends StatefulWidget {
  const ArticlesTabPage({super.key});

  @override
  State<ArticlesTabPage> createState() => _ArticlesTabPageState();
}

class _ArticlesTabPageState extends State<ArticlesTabPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<GlobalKey<ArticlesContentPageState>> _contentPageKeys = [
    GlobalKey<ArticlesContentPageState>(),
    GlobalKey<ArticlesContentPageState>(),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "articles.title".tr(context),
          style: TextStyle(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: AppColors.primaryColor),
            onPressed:
                () =>
                    _contentPageKeys[_tabController.index].currentState
                        ?.toggleSearchVisibility(),
            color: AppColors.primaryColor,
          ),
          IconButton(
            icon: Icon(Icons.filter_list, color: AppColors.primaryColor),
            onPressed:
                () =>
                    _contentPageKeys[_tabController.index].currentState
                        ?.showFilterDialog(),
            color: AppColors.primaryColor,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,

          labelColor: AppColors.primaryColor,
          indicatorColor: AppColors.primaryColor,
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(text: 'articles.tap.all_articles'.tr(context)),
            Tab(text: 'articles.tap.my_articles'.tr(context)),
          ],
        ),
      ),
      floatingActionButton:
          _tabController.index == 1
              ? FloatingActionButton(
                onPressed: () => context.pushNamed(AppRouter.addArticle.name),
                child: const Icon(Icons.add),
              )
              : null,
      body: TabBarView(
        controller: _tabController,
        children: [
          ArticlesContentPage(key: _contentPageKeys[0], isMyArticles: false),
          ArticlesContentPage(key: _contentPageKeys[1], isMyArticles: true),
        ],
      ),
    );
  }
}
