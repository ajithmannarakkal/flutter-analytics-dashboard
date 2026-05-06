import 'package:dio/dio.dart';
import 'api_constants.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logger_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import '../storage/secure_storage_service.dart';

class DioClient {
  late final Dio dio;

  DioClient(SecureStorageService storageService) {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeout),
        receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
        responseType: ResponseType.json,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.addAll([
      AuthInterceptor(storageService),
      LoggerInterceptor(),
      ErrorInterceptor(),
    ]);
  }

  // Generic GET
  Future<Response> get(String url, {Map<String, dynamic>? queryParameters}) async {
    return await dio.get(url, queryParameters: queryParameters);
  }

  // Generic POST
  Future<Response> post(String url, {dynamic data}) async {
    return await dio.post(url, data: data);
  }

  // Generic PUT
  Future<Response> put(String url, {dynamic data}) async {
    return await dio.put(url, data: data);
  }

  // Generic DELETE
  Future<Response> delete(String url) async {
    return await dio.delete(url);
  }
}
