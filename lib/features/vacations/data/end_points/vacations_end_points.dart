class VacationEndPoints {
  static String getVacations({required String scheduleId}) => "/practitioner/vacations/$scheduleId";

  static String viewVacation({required String id}) => "/practitioner/vacation/$id";

  static String deleteVacation({required int id}) => "/practitioner/vacations/$id";

  static const String createVacation = "/practitioner/vacations";

  static String updateVacation({required int id}) => "/practitioner/vacations/$id/update";
}
