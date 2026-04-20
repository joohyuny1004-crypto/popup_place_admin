import 'package:flutter/material.dart';

import '../../app/theme/admin_colors.dart';
import '../../shared/widgets/stat_card.dart';

enum _IStatus { waiting, answered, closed }

class _Inquiry {
  _Inquiry({
    required this.id,
    required this.userName,
    required this.type,
    required this.title,
    required this.content,
    required this.date,
    required this.status,
    this.answer,
  });
  final String id;
  final String userName;
  final String type;
  final String title;
  final String content;
  final String date;
  _IStatus status;
  String? answer;
}

final _dummyInquiries = [
  _Inquiry(id: 'Q001', userName: '홍길동', type: '예약/결제', title: '카카오페이 결제 후 예약이 확인되지 않아요', content: '카카오페이로 결제를 완료했는데 예약 내역에서 확인이 안 됩니다. 결제 금액은 차감되었습니다.', date: '2025.04.18', status: _IStatus.answered, answer: '결제 처리 중 일시적인 오류가 발생했습니다. 예약 내역에 반영되었으니 확인해 주세요.'),
  _Inquiry(id: 'Q002', userName: '이서준', type: '환불/취소', title: '예약 취소 환불 기간이 얼마나 걸리나요?', content: '예약을 취소했는데 환불이 언제 되는지 알고 싶습니다.', date: '2025.04.15', status: _IStatus.answered, answer: '환불은 취소 신청 후 3~5 영업일 이내에 처리됩니다.'),
  _Inquiry(id: 'Q003', userName: '박지영', type: '앱 오류', title: '지도 화면이 표시되지 않아요', content: '지도 보기 버튼을 눌러도 지도가 표시되지 않고 빈 화면만 나옵니다.', date: '2025.04.19', status: _IStatus.waiting),
  _Inquiry(id: 'Q004', userName: '정다은', type: '공간 등록', title: '공간 사진 업로드가 안 돼요', content: '공간 등록 시 사진 업로드 버튼을 누르면 아무 반응이 없습니다.', date: '2025.04.19', status: _IStatus.waiting),
  _Inquiry(id: 'Q005', userName: '강현수', type: '계정 관련', title: '비밀번호 변경이 안 됩니다', content: '프로필 설정에서 비밀번호를 변경하려고 하는데 저장이 안 됩니다.', date: '2025.04.17', status: _IStatus.closed),
];

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  String _filterStatus = '전체';

  List<_Inquiry> get _filtered {
    if (_filterStatus == '전체') return _dummyInquiries;
    final status = switch (_filterStatus) {
      '대기중' => _IStatus.waiting,
      '답변완료' => _IStatus.answered,
      _ => _IStatus.closed,
    };
    return _dummyInquiries.where((q) => q.status == status).toList();
  }

  Color _statusColor(_IStatus s) => switch (s) {
        _IStatus.waiting => AdminColors.warning,
        _IStatus.answered => AdminColors.success,
        _IStatus.closed => AdminColors.textDisabled,
      };

  String _statusLabel(_IStatus s) => switch (s) {
        _IStatus.waiting => '대기중',
        _IStatus.answered => '답변완료',
        _IStatus.closed => '종료',
      };

  void _showAnswerDialog(_Inquiry inquiry) {
    final ctrl = TextEditingController(text: inquiry.answer ?? '');

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('문의 답변 - ${inquiry.id}'),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AdminColors.contentBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('[${inquiry.type}] ${inquiry.title}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 6),
                    Text(inquiry.content,
                        style: const TextStyle(
                            fontSize: 12, color: AdminColors.textSecondary)),
                    const SizedBox(height: 4),
                    Text('작성자: ${inquiry.userName} · ${inquiry.date}',
                        style: const TextStyle(
                            fontSize: 11, color: AdminColors.textDisabled)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('답변 내용',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 8),
              TextField(
                controller: ctrl,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: '답변 내용을 입력해주세요',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                inquiry.answer = ctrl.text;
                inquiry.status = _IStatus.answered;
              });
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('답변이 등록되었습니다.')),
              );
            },
            child: const Text('답변 등록'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final waitingCount = _dummyInquiries.where((q) => q.status == _IStatus.waiting).length;
    final answeredCount = _dummyInquiries.where((q) => q.status == _IStatus.answered).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 요약
          Row(
            children: [
              _SupportStatCard(label: '전체 문의', value: '${_dummyInquiries.length}', color: AdminColors.primary, icon: Icons.inbox_rounded),
              const SizedBox(width: 12),
              _SupportStatCard(label: '답변 대기', value: '$waitingCount', color: AdminColors.warning, icon: Icons.pending_rounded),
              const SizedBox(width: 12),
              _SupportStatCard(label: '답변 완료', value: '$answeredCount', color: AdminColors.success, icon: Icons.check_circle_rounded),
            ],
          ),
          const SizedBox(height: 20),

          // 필터
          Row(
            children: [
              ...['전체', '대기중', '답변완료', '종료'].map((s) {
                final selected = _filterStatus == s;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(s),
                    selected: selected,
                    onSelected: (_) => setState(() => _filterStatus = s),
                    selectedColor: AdminColors.primary,
                    showCheckmark: false,
                    labelStyle: TextStyle(
                      color:
                          selected ? Colors.white : AdminColors.textSecondary,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                      fontSize: 12,
                    ),
                    side: BorderSide(
                      color: selected
                          ? AdminColors.primary
                          : AdminColors.cardBorder,
                    ),
                    backgroundColor: AdminColors.cardBg,
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 16),

          // 문의 목록
          SectionCard(
            title: '고객 문의',
            subtitle: '${_filtered.length}건',
            child: Column(
              children: _filtered.map((q) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(
                        top: BorderSide(color: AdminColors.cardBorder)),
                  ),
                  child: Row(
                    children: [
                      // 상태 표시
                      StatusBadge(
                        label: _statusLabel(q.status),
                        color: _statusColor(q.status),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AdminColors.contentBg,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(q.type,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: AdminColors.textSecondary,
                                      )),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(q.title,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${q.userName} · ${q.date}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AdminColors.textSecondary,
                              ),
                            ),
                            if (q.answer != null) ...[
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AdminColors.successLight,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.reply_rounded,
                                        size: 13, color: AdminColors.success),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(q.answer!,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AdminColors.success,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (q.status == _IStatus.waiting)
                        ElevatedButton(
                          onPressed: () => _showAnswerDialog(q),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                          ),
                          child: const Text('답변하기',
                              style: TextStyle(fontSize: 12)),
                        )
                      else
                        OutlinedButton(
                          onPressed: () => _showAnswerDialog(q),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AdminColors.primary,
                            side: const BorderSide(
                                color: AdminColors.cardBorder),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                          ),
                          child: const Text('수정',
                              style: TextStyle(fontSize: 12)),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportStatCard extends StatelessWidget {
  const _SupportStatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AdminColors.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AdminColors.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AdminColors.textPrimary)),
                Text(label,
                    style: const TextStyle(
                        fontSize: 11, color: AdminColors.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
