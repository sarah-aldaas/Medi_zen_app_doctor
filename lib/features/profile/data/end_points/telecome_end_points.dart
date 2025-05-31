class TelecomEndPoints{
  static String listAllTelecom({required String paginationCount}) => "/practitioner/telecoms?pagination_count=$paginationCount";
  static String createTelecom = "/practitioner/telecoms";
  static String updateTelecom({required String id}) => "/practitioner/telecoms/$id";
  static String deleteTelecom({required String id}) => "/practitioner/telecoms/$id";
  static String showTelecom({required String id}) => "/practitioner/telecoms/$id";
}
