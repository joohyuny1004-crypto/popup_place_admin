import 'package:supabase_flutter/supabase_flutter.dart';

import 'models.dart';

class InquiriesRepository {
  InquiriesRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<Inquiry>> fetchAll() async {
    final rows = await _client
        .from('inquiries')
        .select(
            '*, profiles(name, email), inquiry_replies(content, created_at)')
        .order('created_at', ascending: false);
    return (rows as List)
        .map((e) => Inquiry.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> answer({
    required String inquiryId,
    required String content,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('로그인이 필요합니다.');

    final existing = await _client
        .from('inquiry_replies')
        .select('id')
        .eq('inquiry_id', inquiryId)
        .maybeSingle();

    if (existing == null) {
      await _client.from('inquiry_replies').insert({
        'inquiry_id': inquiryId,
        'admin_id': userId,
        'content': content,
      });
    } else {
      await _client
          .from('inquiry_replies')
          .update({'content': content}).eq('id', existing['id']);
    }

    await _client
        .from('inquiries')
        .update({'status': 'answered'}).eq('id', inquiryId);
  }

  Future<void> setStatus(String inquiryId, InquiryStatus status) async {
    await _client
        .from('inquiries')
        .update({'status': status.name}).eq('id', inquiryId);
  }
}
