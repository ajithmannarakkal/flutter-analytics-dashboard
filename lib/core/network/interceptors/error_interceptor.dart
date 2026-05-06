import 'package:dio/dio.dart';
import '../api_exception.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Transform DioException into our custom ApiException
    final apiException = ApiException.fromDioError(err);
    
    // Create a new DioException with the custom error
    final newErr = err.copyWith(error: apiException);
    
    super.onError(newErr, handler);
  }
}
