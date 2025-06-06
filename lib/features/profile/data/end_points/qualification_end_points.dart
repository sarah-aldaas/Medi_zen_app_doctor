class QualificationEndPoints {
  static String listAllQualifications({required String paginationCount}) =>
      "/practitioner/qualifications?pagination_count=$paginationCount";
  static String createQualification = "/practitioner/qualifications";
  static String updateQualification({required String id}) =>
      "/practitioner/qualifications/$id";
  static String deleteQualification({required String id}) =>
      "/practitioner/qualifications/$id";
  static String showQualification({required String id}) =>
      "/practitioner/qualifications/$id";
}