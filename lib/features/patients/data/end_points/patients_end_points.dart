class PatientEndPoints {
  static String listPatients = "/practitioner/patients";

  static String showPatient({required int id}) => "/practitioner/patients/$id";

  static String updatePatient({required int id}) => "/practitioner/patients/$id";

  static String toggleActiveStatus({required int id}) => "/practitioner/patients/$id/toggle-status";

  static String toggleDeceasedStatus({required int id}) => "/practitioner/patients/$id/toggle-deceased-status";
}
