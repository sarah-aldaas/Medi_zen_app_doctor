class ArticlesEndPoints {
  static String getAllArticles() => "/practitioner/articles";

  static String getMyArticles() => "/practitioner/my-articles";

  static String createArticles() => "/practitioner/articles";

  static String getDetailsArticle({required String articleId}) => "/practitioner/articles/$articleId";

  static String updateArticle({required String articleId}) => "/practitioner/articles/$articleId";

  static String deleteArticle({required String articleId}) => "/practitioner/articles/$articleId";
}
