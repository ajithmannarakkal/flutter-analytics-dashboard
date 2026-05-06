import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/secure_storage_service.dart';
import 'dio_client.dart';

final dioClientProvider = Provider<DioClient>((ref) {
  final storageService = ref.watch(secureStorageProvider);
  return DioClient(storageService);
});
