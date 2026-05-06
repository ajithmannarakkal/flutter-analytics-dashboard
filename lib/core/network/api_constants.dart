class ApiConstants {
  static const String baseUrl = 'https://critter-liver-bodacious.ngrok-free.dev';
  
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;

  // Auth endpoints
  static const String login = '/api/auth/login';

  // Admin endpoints
  static const String users = '/api/admin/users';
  static String resetPassword(String id) => '/api/admin/users/$id/reset-password';
  static String disableUser(String id) => '/api/admin/users/$id/disable';
  static String deleteUser(String id) => '/api/admin/users/$id';

  // Analytics endpoints
  static const String revenue = '/api/dashboard/revenue';
  static const String salesSummary = '/api/dashboard/sales-summary';
  static const String countries = '/api/dashboard/countries';
  static String states(String country) => '/api/dashboard/states/$country';
  static String cities(String state) => '/api/dashboard/cities/$state';
  static const String hourlyGrowth = '/api/dashboard/hourly-growth';
}
