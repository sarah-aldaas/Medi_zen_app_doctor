class TelecomEndPoints {
  static String listAllTelecom({
    required String rank,
    required String paginationCount,
  }) => "/patient/telecoms?rank=$rank&pagination_count=$paginationCount";
  static String createTelecom = "/patient/telecoms";
  static String updateTelecom({required String id}) => "/patient/telecoms/$id";
  static String deleteTelecom({required String id}) => "/patient/telecoms/$id";
  static String showTelecom({required String id}) => "/patient/telecoms/$id";
}
