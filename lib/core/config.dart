/// Compile-time configuration. Override at build time with:
///   flutter build web --dart-define=SUPABASE_URL=https://... --dart-define=SUPABASE_ANON_KEY=...
class AppConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://mtmbczgdfwkslqkkkqll.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'sb_publishable_3-i50-2F1hrTcQXs3mGrWg_6jwvYUck',
  );
}
