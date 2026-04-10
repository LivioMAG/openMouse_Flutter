import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';

class SupabaseClientService {
  static Future<void> init(AppConfig config) async {
    await Supabase.initialize(
      url: config.supabaseUrl,
      anonKey: config.supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
