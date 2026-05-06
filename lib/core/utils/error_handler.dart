import 'package:dio/dio.dart';
import '../network/api_exception.dart';

class ErrorHandler {
  /// Converts various exception types into a user-friendly error message.
  static String getMessage(dynamic error) {
    if (error is ApiException) {
      return error.message;
    }
    
    if (error is DioException) {
      if (error.error is ApiException) {
        return (error.error as ApiException).message;
      }
      return error.message ?? 'A network error occurred';
    }
    
    return error.toString();
  }
}
