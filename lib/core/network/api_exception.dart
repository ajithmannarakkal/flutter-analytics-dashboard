class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() => message;

  factory ApiException.fromDioError(dynamic error) {
    if (error.runtimeType.toString() == 'DioException') {
      final dioError = error as dynamic;
      final statusCode = dioError.response?.statusCode;
      
      String message = 'Unexpected error occurred';
      if (dioError.response?.data != null && dioError.response?.data is Map) {
        message = dioError.response?.data['message'] ?? message;
      }

      switch (dioError.type.toString()) {
        case 'DioExceptionType.connectionTimeout':
        case 'DioExceptionType.sendTimeout':
        case 'DioExceptionType.receiveTimeout':
          message = 'Connection timeout';
          break;
        case 'DioExceptionType.badResponse':
          switch (statusCode) {
            case 400:
              message = message != 'Unexpected error occurred' ? message : 'Bad request';
              break;
            case 401:
              message = message != 'Unexpected error occurred' ? message : 'Unauthorized access';
              break;
            case 403:
              message = message != 'Unexpected error occurred' ? message : 'Forbidden access';
              break;
            case 404:
              message = 'Resource not found';
              break;
            case 409:
              message = message != 'Unexpected error occurred' ? message : 'Conflict occurred';
              break;
            case 500:
              message = 'Internal server error';
              break;
          }
          break;
        case 'DioExceptionType.connectionError':
          message = 'No internet connection';
          break;
        default:
          break;
      }
      return ApiException(message, statusCode: statusCode, data: dioError.response?.data);
    }
    return ApiException(error.toString());
  }
}
