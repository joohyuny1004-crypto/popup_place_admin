import 'package:supabase_flutter/supabase_flutter.dart';

import 'models.dart';

class NoticesRepository {
  NoticesRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<Notice>> fetchAll() async {
    final rows = await _client
        .from('notices')
        .select()
        .order('is_pinned', ascending: false)
        .order('created_at', ascending: false);
    return (rows as List)
        .map((e) => Notice.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<Notice> create({
    required String title,
    required String content,
    required String category,
    bool isPinned = false,
  }) async {
    final row = await _client
        .from('notices')
        .insert({
          'title': title,
          'content': content,
          'category': category,
          'is_pinned': isPinned,
        })
        .select()
        .single();
    return Notice.fromMap(row);
  }

  Future<void> update({
    required String id,
    required String title,
    required String content,
    required String category,
  }) async {
    await _client.from('notices').update({
      'title': title,
      'content': content,
      'category': category,
    }).eq('id', id);
  }

  Future<void> setPinned(String id, bool pinned) async {
    await _client.from('notices').update({'is_pinned': pinned}).eq('id', id);
  }

  Future<void> remove(String id) async {
    await _client.from('notices').delete().eq('id', id);
  }
}
