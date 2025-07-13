class NotificationEndPoints {
  static String storeFCMToken() => "/practitioner/device-tokens";

  static String deleteFCMToken() => "/practitioner/device-tokens/delete-fcm";

  static String getMyNotification() => "/practitioner/notifications";

  static String makeNotificationAsRead({required String notificationId}) => "/practitioner/notifications/$notificationId/read";

  static String deleteNotification({required String notificationId}) => "/practitioner/notifications/$notificationId";
}
