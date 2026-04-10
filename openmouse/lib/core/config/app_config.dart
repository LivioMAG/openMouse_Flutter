class AppConfig {
  const AppConfig({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.storageBucket,
    required this.appName,
  });

  final String supabaseUrl;
  final String supabaseAnonKey;
  final String storageBucket;
  final String appName;
}
