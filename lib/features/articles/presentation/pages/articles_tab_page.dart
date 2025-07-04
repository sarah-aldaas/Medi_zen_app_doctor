import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
import 'package:medi_zen_app_doctor/features/articles/presentation/pages/articles_content_page.dart';

import '../../../../base/go_router/go_router.dart';

class ArticlesTabPage extends StatefulWidget {
  const ArticlesTabPage({super.key});

  @override
  State<ArticlesTabPage> createState() => _ArticlesTabPageState();
}

class _ArticlesTabPageState extends State<ArticlesTabPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<GlobalKey<ArticlesContentPageState>> _contentPageKeys = [GlobalKey<ArticlesContentPageState>(), GlobalKey<ArticlesContentPageState>()];

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
        title: Text("articles.title".tr(context)),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () => _contentPageKeys[_tabController.index].currentState?.toggleSearchVisibility()),
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () => _contentPageKeys[_tabController.index].currentState?.showFilterDialog()),
        ],
        bottom: TabBar(controller: _tabController, tabs: [Tab(text: "All Articles".tr(context)), Tab(text: "My Articles".tr(context))]),
      ),
      floatingActionButton:
          _tabController.index == 1 ? FloatingActionButton(onPressed: () => context.pushNamed(AppRouter.addArticle.name), child: const Icon(Icons.add)) : null,
      body: TabBarView(
        controller: _tabController,
        children: [ArticlesContentPage(key: _contentPageKeys[0], isMyArticles: false), ArticlesContentPage(key: _contentPageKeys[1], isMyArticles: true)],
      ),
    );
  }
}
