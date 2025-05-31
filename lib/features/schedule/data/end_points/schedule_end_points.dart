class ScheduleEndPoints {
  static String showMySchedules({String? paginationCount}) =>
      paginationCount != null ? "/practitioner/show-my-schedules?pagination_count=$paginationCount" : "/practitioner/show-my-schedules";

  static String showSchedule({required String id}) => "/practitioner/schedule/$id";

  static String toggleScheduleStatus({required String id}) => "/practitioner/schedules/$id/toggle-active";

  static const String createSchedule = "/practitioner/schedules";

  static String updateSchedule({required String id}) => "/practitioner/schedules/$id/update";
}
