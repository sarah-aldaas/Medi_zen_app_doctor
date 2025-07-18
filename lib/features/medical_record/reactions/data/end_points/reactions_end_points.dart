class ReactionEndPoints {
  static String listAllergyReactions({
    required int patientId,
    required int allergyId,
  }) => "/practitioner/patients/$patientId/allergies/$allergyId/reactions";

  static String create({
    required String patientId,
    required String allergyId,
  }) => "/practitioner/patients/$patientId/allergies/$allergyId/reactions";

  static String view({
    required String patientId,
    required String allergyId,
    required String reactionId,
  }) => "/practitioner/patients/$patientId/allergies/$allergyId/reactions/$reactionId";

  static String update({
    required String patientId,
    required String allergyId,
    required String reactionId,
  }) => "/practitioner/patients/$patientId/allergies/$allergyId/reactions/$reactionId";

  static String delete({
    required String patientId,
    required String allergyId,
    required String reactionId,
  }) => "/practitioner/patients/$patientId/allergies/$allergyId/reactions/$reactionId";

  static String byAppointment({
    required int patientId,
    required int appointmentId,
    required int allergyId,
  }) => "/practitioner/patients/$patientId/appointments/$appointmentId/allergies/$allergyId/reactions";
}