import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';

import '../../../../base/blocs/code_types_bloc/code_types_cubit.dart';
import '../../../../base/data/models/code_type_model.dart';
import '../../../../base/theme/app_color.dart';
import '../../../../base/widgets/loading_page.dart';
import '../../data/model/article_filter_model.dart';
import '../../data/model/article_model.dart';
import '../cubit/article_cubit/article_cubit.dart';
import 'article_details_page.dart';

class ArticlesPage extends StatefulWidget {
  const ArticlesPage({super.key});

  @override
  State<ArticlesPage> createState() => _ArticlesPageState();
}

class _ArticlesPageState extends State<ArticlesPage> {
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
    context.read<ArticleCubit>().getAllArticles(
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
          .getAllArticles(
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
      context.read<ArticleCubit>().getAllArticles(
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
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios, color: AppColors.primaryColor),
        ),
        title: Text(
          "articles.title".tr(context),
          style: TextStyle(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: _buildAppBarActions(),
      ),
      body: Column(
        children: [
          if (_showSearchField) _buildSearchField(),
          Expanded(
            child: BlocConsumer<ArticleCubit, ArticleState>(
              listener: (context, state) {
                if (state is ArticleError) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.error)));
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
                          child: Text("Retry"),
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
        icon: Icon(Icons.search, color: AppColors.primaryColor),
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
          prefixIcon: Icon(Icons.search, color: AppColors.primaryColor),
          suffixIcon: IconButton(
            icon: Icon(Icons.close, color: AppColors.primaryColor),
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
        await context.read<ArticleCubit>().getAllArticles(
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

                    // Text(
                    //   article.content ?? 'No description',
                    //   style: TextStyle(fontSize: 12, color: Colors.grey),
                    //   maxLines: 2,
                    //   overflow: TextOverflow.ellipsis,
                    // ),
                    // const SizedBox(height: 4),
                    Text(
                      article.createdAt?.toLocal().toString().split(' ')[0] ??
                          '',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
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
              title: Text(
                "articles.filters.title".tr(context),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  // mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "articles.filters.sortBy".tr(context),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
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
                    Text(
                      "articles.filters.category".tr(context),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
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
                  child: Text(
                    'articles.cancel'.tr(context),
                    style: TextStyle(
                      color: AppColors.whiteColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, {
                      'sort': tempSort,
                      'categoryId': tempCategoryId,
                      'categoryDisplay': tempCategoryDisplay,
                    });
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
                  child: Text(
                    'articles.apply'.tr(context),
                    style: TextStyle(
                      color: AppColors.whiteColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
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
