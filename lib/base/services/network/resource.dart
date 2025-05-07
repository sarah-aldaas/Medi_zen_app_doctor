abstract class Resource<T> {
  bool get isSuccess => this is Success;

  bool get isFailed => this is Error;

  R fold<R>({
    required R Function(T data) success,
    required R Function(String? message, int? code, T? data) error,
  }) {
    if (this is Success) {
      final successResource = this as Success<T>;
      return success(successResource.data!);
    } else {
      final errorResource = this as ResponseError<T>;
      return error(errorResource.message, errorResource.code, errorResource.data);
    }
  }
}

class Success<T> extends Resource<T> {
  final T data;

  Success({required this.data});
}

class ResponseError<T> extends Resource<T> {
  final T? data;
  final String? message;
  final int? code;

  ResponseError({this.data, this.message, this.code}) {
    // Utilities.showSnackBar(message!);
  }
}
