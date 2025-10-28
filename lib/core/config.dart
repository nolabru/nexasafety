class Config {
  // Base URL para desenvolvimento (ajustável via --dart-define)
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://disclose-acrobat-owned-entered.trycloudflare.com/api/v1',
  );

  // HERE API Key (ajustável via --dart-define)
  static const String hereApiKey = String.fromEnvironment(
    'HERE_API_KEY',
    defaultValue: 'AL6ZtjRErY8VzI4vPOQIwNaZLFsnotEXZvBIlF1hiDo',
  );

  static bool get isProduction => const bool.fromEnvironment('dart.vm.product');
}
