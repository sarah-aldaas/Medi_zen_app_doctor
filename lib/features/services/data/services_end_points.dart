class ServicesEndPoints {
  static String getAllHealthCareServices = "/healthcare-services";

  static String getSpecificHealthCareServices({required String id}) => "/healthcare-services/$id";

  static String getAllHealthCareServiceEligibilityCodes = "/health-care-service-eligibility-codes";

  static String getSpecificHealthCareServiceEligibilityCodes({required String id}) => "/health-care-service-eligibility-codes/$id";
}
