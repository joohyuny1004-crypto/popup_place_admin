enum InquiryStatus { waiting, answered, closed }

InquiryStatus inquiryStatusFromString(String? s) => switch (s) {
      'answered' => InquiryStatus.answered,
      'closed' => InquiryStatus.closed,
      _ => InquiryStatus.waiting,
    };

String _fmt(DateTime d) =>
    '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';

class Notice {
  Notice({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.isPinned,
    required this.createdAt,
  });

  factory Notice.fromMap(Map<String, dynamic> m) => Notice(
        id: m['id'] as String,
        title: (m['title'] as String?) ?? '',
        content: (m['content'] as String?) ?? '',
        category: (m['category'] as String?) ?? '공지',
        isPinned: (m['is_pinned'] as bool?) ?? false,
        createdAt: DateTime.parse(m['created_at'] as String).toLocal(),
      );

  final String id;
  String title;
  String content;
  String category;
  bool isPinned;
  final DateTime createdAt;

  String get dateLabel => _fmt(createdAt);
}

class Inquiry {
  Inquiry({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.content,
    required this.status,
    required this.createdAt,
    this.userName,
    this.userEmail,
    this.answer,
    this.answeredAt,
  });

  factory Inquiry.fromMap(Map<String, dynamic> m) {
    final profile = m['profiles'];
    String? name;
    String? email;
    if (profile is Map) {
      name = profile['name'] as String?;
      email = profile['email'] as String?;
    }
    final replies = m['inquiry_replies'];
    String? answer;
    DateTime? answeredAt;
    if (replies is List && replies.isNotEmpty) {
      final first = replies.first as Map<String, dynamic>;
      answer = first['content'] as String?;
      final at = first['created_at'] as String?;
      if (at != null) answeredAt = DateTime.parse(at).toLocal();
    }
    return Inquiry(
      id: m['id'] as String,
      userId: m['user_id'] as String,
      type: (m['type'] as String?) ?? '기타',
      title: (m['title'] as String?) ?? '',
      content: (m['content'] as String?) ?? '',
      status: inquiryStatusFromString(m['status'] as String?),
      createdAt: DateTime.parse(m['created_at'] as String).toLocal(),
      userName: name,
      userEmail: email,
      answer: answer,
      answeredAt: answeredAt,
    );
  }

  final String id;
  final String userId;
  String type;
  String title;
  String content;
  InquiryStatus status;
  final DateTime createdAt;
  String? userName;
  String? userEmail;
  String? answer;
  DateTime? answeredAt;

  String get dateLabel => _fmt(createdAt);
}
