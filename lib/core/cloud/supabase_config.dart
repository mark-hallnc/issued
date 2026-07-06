class SupabaseConfig {
  const SupabaseConfig._();

  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get isConfigured =>
      supabaseUrl.trim().isNotEmpty && supabaseAnonKey.trim().isNotEmpty;

  static String? get missingConfigMessage {
    if (isConfigured) {
      return null;
    }
    return 'Cloud sign-in is not configured on this build. Provide SUPABASE_URL and SUPABASE_ANON_KEY with --dart-define.';
  }
}
