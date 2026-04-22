import 'package:flutter/material.dart';

import '../../app/theme/admin_colors.dart';
import '../../data/inquiries_repository.dart';
import '../../data/models.dart';
import '../../shared/widgets/stat_card.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  final _repo = InquiriesRepository();
  late Future<List<Inquiry>> _future = _repo.fetchAll();

  String _filterStatus = '전체';

  Future<void> _refresh() async {
    setState(() => _future = _repo.fetchAll());
    await _future;
  }

  Color _statusColor(InquiryStatus s) => switch (s) {
        InquiryStatus.waiting => AdminColors.warning,
        InquiryStatus.answered => AdminColors.success,
        InquiryStatus.closed => AdminColors.textDisabled,
      };

  String _statusLabel(InquiryStatus s) => switch (s) {
        InquiryStatus.waiting => '대기중',
        InquiryStatus.answered => '답변완료',
        InquiryStatus.closed => '종료',
      };

  List<Inquiry> _filter(List<Inquiry> all) {
    if (_filterStatus == '전체') return all;
    final status = switch (_filterStatus) {
      '대기중' => InquiryStatus.waiting,
      '답변완료' => InquiryStatus.answered,
      _ => InquiryStatus.closed,
    };
    return all.where((q) => q.status == status).toList();
  }

  void _showAnswerDialog(Inquiry inquiry) {
    final ctrl = TextEditingController(text: inquiry.answer ?? '');

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('문의 답변 - ${inquiry.id.substring(0, 8)}'),
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
                            fontSize: 12,
                            color: AdminColors.textSecondary)),
                    const SizedBox(height: 4),
                    Text(
                      '작성자: ${inquiry.userName ?? inquiry.userEmail ?? '알수없음'} · ${inquiry.dateLabel}',
                      style: const TextStyle(
                          fontSize: 11, color: AdminColors.textDisabled),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('답변 내용',
                  style:
                      TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 8),
              TextField(
                controller: ctrl,
                maxLines: 5,
                decoration:
                    const InputDecoration(hintText: '답변 내용을 입력해주세요'),
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
            onPressed: () async {
              try {
                await _repo.answer(
                  inquiryId: inquiry.id,
                  content: ctrl.text.trim(),
                );
                if (!mounted) return;
                Navigator.of(ctx).pop();
                await _refresh();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('답변이 등록되었습니다.')),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('답변 등록 실패: $e')));
              }
            },
            child: const Text('답변 등록'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Inquiry>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('불러오기 실패: ${snap.error}'),
                const SizedBox(height: 8),
                ElevatedButton(
                    onPressed: _refresh, child: const Text('다시 시도')),
              ],
            ),
          );
        }
        final all = snap.data ?? const <Inquiry>[];
        final filtered = _filter(all);
        final waitingCount =
            all.where((q) => q.status == InquiryStatus.waiting).length;
        final answeredCount =
            all.where((q) => q.status == InquiryStatus.answered).length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _SupportStatCard(
                      label: '전체 문의',
                      value: '${all.length}',
                      color: AdminColors.primary,
                      icon: Icons.inbox_rounded),
                  const SizedBox(width: 12),
                  _SupportStatCard(
                      label: '답변 대기',
                      value: '$waitingCount',
                      color: AdminColors.warning,
                      icon: Icons.pending_rounded),
                  const SizedBox(width: 12),
                  _SupportStatCard(
                      label: '답변 완료',
                      value: '$answeredCount',
                      color: AdminColors.success,
                      icon: Icons.check_circle_rounded),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  ...['전체', '대기중', '답변완료', '종료'].map((s) {
                    final selected = _filterStatus == s;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(s),
                        selected: selected,
                        onSelected: (_) =>
                            setState(() => _filterStatus = s),
                        selectedColor: AdminColors.primary,
                        showCheckmark: false,
                        labelStyle: TextStyle(
                          color: selected
                              ? Colors.white
                              : AdminColors.textSecondary,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w400,
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
              SectionCard(
                title: '고객 문의',
                subtitle: '${filtered.length}건',
                child: Column(
                  children: filtered.map((q) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        border: Border(
                            top: BorderSide(color: AdminColors.cardBorder)),
                      ),
                      child: Row(
                        children: [
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
                                        borderRadius:
                                            BorderRadius.circular(4),
                                      ),
                                      child: Text(q.type,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color:
                                                AdminColors.textSecondary,
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
                                  '${q.userName ?? q.userEmail ?? '알수없음'} · ${q.dateLabel}',
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
                                      borderRadius:
                                          BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.reply_rounded,
                                            size: 13,
                                            color: AdminColors.success),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(q.answer!,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color:
                                                    AdminColors.success,
                                              ),
                                              maxLines: 1,
                                              overflow:
                                                  TextOverflow.ellipsis),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (q.status == InquiryStatus.waiting)
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
      },
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
                        fontSize: 11,
                        color: AdminColors.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
