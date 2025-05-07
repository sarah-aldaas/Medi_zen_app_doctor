
import '../services/network/resource.dart';
import '../services/network/response_handler.dart';

class Utilities {
  static showInternetConnectionSnackBar(status) {}

  static Future<Resource<T>> handleResponse<T>(response, {bool isListModel = false, required T Function(Map<String, dynamic> json) fromJson}) async {
    final responseHandler = ResponseHandler<T>(response);
    if (isListModel) {}
    return responseHandler.processResponse(fromJson: fromJson);
  }
}
