import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medi_zen_app_doctor/base/blocs/code_types_bloc/code_types_cubit.dart';
import 'package:medi_zen_app_doctor/base/data/models/code_type_model.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
import 'package:medi_zen_app_doctor/base/go_router/go_router.dart';
import 'package:medi_zen_app_doctor/base/widgets/loading_page.dart';
import 'package:medi_zen_app_doctor/base/widgets/show_toast.dart';
import 'package:medi_zen_app_doctor/features/articles/data/model/article_filter_model.dart';
import 'package:medi_zen_app_doctor/features/articles/data/model/article_model.dart';
import 'package:medi_zen_app_doctor/features/articles/presentation/cubit/article_cubit/article_cubit.dart';

import '../../../../base/theme/app_color.dart';
import 'article_details_page.dart';

class ArticlesMyPage extends StatefulWidget {
  const ArticlesMyPage({super.key});

  @override
  State<ArticlesMyPage> createState() => _ArticlesMyPageState();
}

class _ArticlesMyPageState extends State<ArticlesMyPage> {
  final List<String> _sortOptions = [
    "articles.filters.asc",
    "articles.filters.desc",
  ];
  String? _selectedSort;
  String? _selectedCategoryId;
  String? _selectedCategoryDisplay;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _showSearchField = false;
  List<CodeModel> _categories = [];

  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadCategories();
    _loadInitialArticles();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _loadInitialArticles() {
    _isLoadingMore = false;
    context.read<ArticleCubit>().getMyArticles(
      context: context,
      filters: _buildFilters(),
    );
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoadingMore) {
      setState(() => _isLoadingMore = true);
      context
          .read<ArticleCubit>()
          .getMyArticles(
            filters: _buildFilters(),
            loadMore: true,
            context: context,
          )
          .then((_) {
            setState(() => _isLoadingMore = false);
          });
    }
  }

  void _loadCategories() async {
    final categories = await context
        .read<CodeTypesCubit>()
        .articleCategoryTypeCodes(context: context);
    setState(() {
      _categories = categories;
    });
  }

  void _loadArticles() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ArticleCubit>().getMyArticles(
        context: context,
        filters: _buildFilters(),
      );
    });
  }

  Map<String, dynamic> _buildFilters() {
    final filter = ArticleFilter(
      searchQuery:
          _searchController.text.isNotEmpty ? _searchController.text : null,
      sort: _selectedSort != null ? _getSortField() : null,
      categoryId: _selectedCategoryId,
    );
    return filter.toJson();
  }

  String? _getSortField() {
    switch (_selectedSort) {
      case "articles.filters.asc":
        return 'asc';
      case "articles.filters.desc":
        return 'desc';
      default:
        return null;
    }
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
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: _buildAppBarActions(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.pushNamed(AppRouter.addArticle.name);
        },

        child: Icon(Icons.add),
        tooltip: "articles.add.title".tr(context),
        backgroundColor: AppColors.primaryColor.withOpacity(0.7),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          if (_showSearchField) _buildSearchField(),
          Expanded(
            child: BlocConsumer<ArticleCubit, ArticleState>(
              listener: (context, state) {
                if (state is ArticleError) {
                  ShowToast.showToastError(message: state.error);
                } else if (state is ArticleDeleteSuccess) {
                  ShowToast.showToastSuccess(
                    message: "articles.delete.success".tr(context),
                  );
                  _loadInitialArticles();
                }
              },
              builder: (context, state) {
                if (state is ArticleLoading) {
                  return const Center(child: LoadingPage());
                }

                if (state is ArticleError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(state.error),
                        ElevatedButton(
                          onPressed: _loadArticles,
                          child: Text("Retry".tr(context)),
                        ),
                      ],
                    ),
                  );
                }

                if (state is ArticleSuccess || state is ArticleLoading) {
                  return _buildContent(state is ArticleSuccess ? state : null);
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAppBarActions() {
    return [
      IconButton(
        icon: const Icon(Icons.search),
        onPressed: () {
          setState(() {
            _showSearchField = !_showSearchField;
            if (_showSearchField) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _searchFocusNode.requestFocus();
              });
            } else {
              _searchController.clear();
              _loadArticles();
            }
          });
        },
      ),
      IconButton(
        icon: const Icon(Icons.filter_list),
        onPressed: _showFilterDialog,
      ),
    ];
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: "articles.searchHint".tr(context),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              _searchController.clear();
              _loadArticles();
            },
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
        ),
        onSubmitted: (value) {
          _loadArticles();
        },
      ),
    );
  }

  Widget _buildContent(ArticleSuccess? state) {
    final articles = state?.paginatedResponse.paginatedData?.items ?? [];
    final hasMore = state?.hasMore ?? false;

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<ArticleCubit>().getMyArticles(
          context: context,
          filters: _buildFilters(),
        );
      },
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: _buildActiveFilters(),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                if (index < articles.length) {
                  return _buildArticleItem(
                    article: articles[index],
                    context: context,
                  );
                } else if (hasMore) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: LoadingButton(),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }, childCount: articles.length + (hasMore ? 1 : 0)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilters() {
    final activeFilters = <Widget>[];

    if (_selectedSort != null) {
      activeFilters.add(
        Chip(
          label: Text(_selectedSort!.tr(context)),
          onDeleted: () {
            setState(() {
              _selectedSort = null;
              _loadArticles();
            });
          },
        ),
      );
    }

    if (_selectedCategoryId != null) {
      activeFilters.add(
        Chip(
          label: Text(_selectedCategoryDisplay ?? ''),
          onDeleted: () {
            setState(() {
              _selectedCategoryId = null;
              _selectedCategoryDisplay = null;
              _loadArticles();
            });
          },
        ),
      );
    }

    if (_searchController.text.isNotEmpty) {
      activeFilters.add(
        Chip(
          label: Text(_searchController.text),
          onDeleted: () {
            setState(() {
              _searchController.clear();
              _loadArticles();
            });
          },
        ),
      );
    }

    return SliverToBoxAdapter(
      child:
          activeFilters.isNotEmpty
              ? Wrap(spacing: 8, runSpacing: 8, children: activeFilters)
              : const SizedBox.shrink(),
    );
  }

  Widget _buildArticleItem({
    required ArticleModel article,
    required BuildContext context,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _navigateToDetails(article, context),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[200],
                  child:
                      article.imageUrl != null && article.imageUrl!.isNotEmpty
                          ? Image.network(
                            article.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(Icons.article),
                          )
                          : Icon(Icons.article, size: 40),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (article.category != null)
                      Text(
                        article.category!.display,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 12,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      article.title ?? 'No title',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      article.createdAt?.toLocal().toString().split(' ')[0] ??
                          '',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () {
                            context.pushNamed(
                              AppRouter.updateArticle.name,
                              extra: article,
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            size: 20,
                            color: Colors.red,
                          ),
                          onPressed:
                              () => _showDeleteConfirmationDialog(
                                article,
                                context,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(
    ArticleModel article,
    BuildContext context,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("articles.delete.title".tr(context)),
            content: Text("articles.delete.confirm".tr(context)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text("cancel".tr(context)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  "articles.delete.submit".tr(context),
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (result == true) {
      context.read<ArticleCubit>().deleteArticle(
        articleId: article.id!,
        context: context,
      );
    }
  }

  Future<void> _showFilterDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        String? tempSort = _selectedSort;
        String? tempCategoryId = _selectedCategoryId;
        String? tempCategoryDisplay = _selectedCategoryDisplay;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("articles.filters.title".tr(context)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("articles.filters.sortBy".tr(context)),
                    RadioListTile<String?>(
                      title: Text("articles.filters.none".tr(context)),
                      value: null,
                      groupValue: tempSort,
                      onChanged: (value) {
                        setState(() {
                          tempSort = value;
                        });
                      },
                    ),
                    ..._sortOptions.map((option) {
                      return RadioListTile<String>(
                        title: Text(option.tr(context)),
                        value: option,
                        groupValue: tempSort,
                        onChanged: (value) {
                          setState(() {
                            tempSort = value;
                          });
                        },
                      );
                    }).toList(),
                    const SizedBox(height: 16),
                    Text("articles.filters.category".tr(context)),
                    DropdownButtonFormField<String>(
                      value: tempCategoryId,
                      items: [
                        DropdownMenuItem(
                          value: null,
                          child: Text(
                            "articles.filters.allCategories".tr(context),
                          ),
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
                          tempCategoryId = value;
                          tempCategoryDisplay =
                              value != null
                                  ? _categories
                                      .firstWhere((c) => c.id == value)
                                      .display
                                  : null;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("cancel".tr(context)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, {
                      'sort': tempSort,
                      'categoryId': tempCategoryId,
                      'categoryDisplay': tempCategoryDisplay,
                    });
                  },
                  child: Text("apply".tr(context)),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedSort = result['sort'];
        _selectedCategoryId = result['categoryId'];
        _selectedCategoryDisplay = result['categoryDisplay'];
        _loadArticles();
      });
    }
  }

  void _navigateToDetails(ArticleModel article, BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArticleDetailsPage(article: article),
      ),
    ).then((value) {
      _loadInitialArticles();
    });
  }
}
