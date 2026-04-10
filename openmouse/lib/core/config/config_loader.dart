import 'dart:convert';

import 'package:flutter/services.dart';

import 'app_config.dart';

class ConfigLoader {
  static Future<AppConfig> load() async {
    final supabaseRaw =
        await rootBundle.loadString('assets/config/supabase_config.json');
    final integrationsRaw =
        await rootBundle.loadString('assets/config/app_integrations.json');

    final supabaseMap = jsonDecode(supabaseRaw) as Map<String, dynamic>;
    final integrationsMap = jsonDecode(integrationsRaw) as Map<String, dynamic>;

    return AppConfig(
      supabaseUrl: supabaseMap['supabaseUrl'] as String,
      supabaseAnonKey: supabaseMap['supabaseAnonKey'] as String,
      storageBucket: integrationsMap['storageBucket'] as String,
      appName: integrationsMap['appName'] as String? ?? 'OpenMouse',
    );
  }
}
