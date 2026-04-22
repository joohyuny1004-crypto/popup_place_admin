import 'package:supabase_flutter/supabase_flutter.dart';

class AdminAuthRepository {
  AdminAuthRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<String?> loginAsAdmin({
    required String email,
    required String password,
  }) async {
    final res = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final user = res.user;
    if (user == null) {
      throw Exception('로그인에 실패했습니다.');
    }
    final profile = await _client
        .from('profiles')
        .select('role')
        .eq('id', user.id)
        .maybeSingle();
    final role = profile?['role'] as String?;
    if (role != 'admin') {
      await _client.auth.signOut();
      throw Exception('관리자 권한이 없는 계정입니다.');
    }
    return role;
  }

  Future<void> logout() async {
    await _client.auth.signOut();
  }

  bool get isSignedIn => _client.auth.currentUser != null;

  Future<bool> isCurrentAdmin() async {
    final user = _client.auth.currentUser;
    if (user == null) return false;
    final profile = await _client
        .from('profiles')
        .select('role')
        .eq('id', user.id)
        .maybeSingle();
    return (profile?['role'] as String?) == 'admin';
  }
}
