import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config.dart';

class SupabaseBootstrap {
  SupabaseBootstrap._();
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      publishableKey: AppConfig.supabaseAnonKey,
    );
    _initialized = true;
  }

  static SupabaseClient get client => Supabase.instance.client;
}
