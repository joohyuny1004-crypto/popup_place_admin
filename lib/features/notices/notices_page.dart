import 'package:flutter/material.dart';

import '../../app/theme/admin_colors.dart';
import '../../data/models.dart';
import '../../data/notices_repository.dart';
import '../../shared/widgets/stat_card.dart';

class NoticesPage extends StatefulWidget {
  const NoticesPage({super.key});
  @override
  State<NoticesPage> createState() => _NoticesPageState();
}

class _NoticesPageState extends State<NoticesPage> {
  final _repo = NoticesRepository();
  late Future<List<Notice>> _future = _repo.fetchAll();

  Color _catColor(String c) => switch (c) {
        '점검' => AdminColors.error,
        '업데이트' => AdminColors.primary,
        '정책' => AdminColors.warning,
        _ => AdminColors.info,
      };

  Future<void> _refresh() async {
    setState(() => _future = _repo.fetchAll());
    await _future;
  }

  void _showEditDialog({Notice? existing}) {
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final contentCtrl = TextEditingController(text: existing?.content ?? '');
    String category = existing?.category ?? '공지';

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text(existing == null ? '공지사항 등록' : '공지사항 수정'),
          content: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: ['공지', '업데이트', '점검', '정책']
                      .map((c) => Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: GestureDetector(
                              onTap: () => setS(() => category = c),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: category == c
                                      ? _catColor(c)
                                      : AdminColors.contentBg,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: category == c
                                        ? _catColor(c)
                                        : AdminColors.cardBorder,
                                  ),
                                ),
                                child: Text(
                                  c,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: category == c
                                        ? Colors.white
                                        : AdminColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: '제목'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contentCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: '내용'),
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
                  if (existing == null) {
                    await _repo.create(
                      title: titleCtrl.text.trim(),
                      content: contentCtrl.text.trim(),
                      category: category,
                    );
                  } else {
                    await _repo.update(
                      id: existing.id,
                      title: titleCtrl.text.trim(),
                      content: contentCtrl.text.trim(),
                      category: category,
                    );
                  }
                  if (!mounted) return;
                  Navigator.of(ctx).pop();
                  await _refresh();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        existing == null ? '공지가 등록되었습니다.' : '공지가 수정되었습니다.'),
                  ));
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('저장 실패: $e')));
                }
              },
              child: Text(existing == null ? '등록' : '수정'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _togglePin(Notice n) async {
    try {
      await _repo.setPinned(n.id, !n.isPinned);
      await _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('핀 변경 실패: $e')));
    }
  }

  Future<void> _delete(Notice n) async {
    try {
      await _repo.remove(n.id);
      await _refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('공지가 삭제되었습니다.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('삭제 실패: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Notice>>(
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
                ElevatedButton(onPressed: _refresh, child: const Text('다시 시도')),
              ],
            ),
          );
        }
        final notices = snap.data ?? const <Notice>[];
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionCard(
                title: '공지사항 관리',
                subtitle: '${notices.length}건',
                action: ElevatedButton.icon(
                  onPressed: () => _showEditDialog(),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('공지 등록',
                      style: TextStyle(fontSize: 13)),
                ),
                child: Column(
                  children: notices.map((n) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: const BoxDecoration(
                          border: Border(
                              top: BorderSide(color: AdminColors.cardBorder)),
                        ),
                        child: Row(
                          children: [
                            if (n.isPinned)
                              const Padding(
                                padding: EdgeInsets.only(right: 8),
                                child: Icon(Icons.push_pin_rounded,
                                    size: 15, color: AdminColors.error),
                              ),
                            StatusBadge(
                                label: n.category,
                                color: _catColor(n.category)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(n.title,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600),
                                      overflow: TextOverflow.ellipsis),
                                  Text(n.dateLabel,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: AdminColors.textSecondary)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              icon: Icon(
                                n.isPinned
                                    ? Icons.push_pin_rounded
                                    : Icons.push_pin_outlined,
                                size: 18,
                                color: n.isPinned
                                    ? AdminColors.error
                                    : AdminColors.textDisabled,
                              ),
                              onPressed: () => _togglePin(n),
                              tooltip: n.isPinned ? '핀 해제' : '핀 설정',
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined,
                                  size: 18,
                                  color: AdminColors.textSecondary),
                              onPressed: () => _showEditDialog(existing: n),
                              tooltip: '수정',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  size: 18, color: AdminColors.error),
                              onPressed: () => _delete(n),
                              tooltip: '삭제',
                            ),
                          ],
                        ),
                      )).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
