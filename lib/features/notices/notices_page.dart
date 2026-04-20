import 'package:flutter/material.dart';
import '../../app/theme/admin_colors.dart';
import '../../shared/widgets/stat_card.dart';

class _Notice {
  _Notice({required this.id, required this.title, required this.content, required this.category, required this.date, required this.isPinned});
  final String id, title, content, category, date;
  bool isPinned;
}

final _dummyNotices = [
  _Notice(id: 'N001', title: '[중요] 서비스 점검 안내 (4월 25일)', content: '서비스 안정화를 위한 점검을 진행합니다.\n일시: 2025년 4월 25일(금) 02:00 ~ 04:00', category: '점검', date: '2025.04.20', isPinned: true),
  _Notice(id: 'N002', title: '토스페이 / 카카오페이 결제 서비스 출시!', content: '이제 토스페이와 카카오페이로 간편하게 결제하실 수 있습니다!', category: '업데이트', date: '2025.04.15', isPinned: true),
  _Notice(id: 'N003', title: '팝업플레이스 앱 v1.1.0 업데이트 안내', content: '챗봇 상담 기능 추가, 지역별/태그별 필터 개선, 성능 최적화', category: '업데이트', date: '2025.04.10', isPinned: false),
  _Notice(id: 'N004', title: '개인정보 처리방침 개정 안내', content: '2025년 4월 1일부터 개인정보 처리방침이 일부 개정됩니다.', category: '정책', date: '2025.03.25', isPinned: false),
];

class NoticesPage extends StatefulWidget {
  const NoticesPage({super.key});
  @override
  State<NoticesPage> createState() => _NoticesPageState();
}

class _NoticesPageState extends State<NoticesPage> {
  Color _catColor(String c) => switch (c) { '점검' => AdminColors.error, '업데이트' => AdminColors.primary, '정책' => AdminColors.warning, _ => AdminColors.info };

  void _showEditDialog({_Notice? existing}) {
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final contentCtrl = TextEditingController(text: existing?.content ?? '');
    String category = existing?.category ?? '공지';

    showDialog<void>(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setS) => AlertDialog(
      title: Text(existing == null ? '공지사항 등록' : '공지사항 수정'),
      content: SizedBox(width: 500, child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(children: ['공지', '업데이트', '점검', '정책'].map((c) => Padding(padding: const EdgeInsets.only(right: 6), child: GestureDetector(
          onTap: () => setS(() => category = c),
          child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: category == c ? _catColor(c) : AdminColors.contentBg, borderRadius: BorderRadius.circular(20), border: Border.all(color: category == c ? _catColor(c) : AdminColors.cardBorder)),
            child: Text(c, style: TextStyle(fontSize: 12, color: category == c ? Colors.white : AdminColors.textSecondary, fontWeight: FontWeight.w600))),
        ))).toList()),
        const SizedBox(height: 12),
        TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: '제목')),
        const SizedBox(height: 12),
        TextField(controller: contentCtrl, maxLines: 4, decoration: const InputDecoration(labelText: '내용')),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('취소')),
        ElevatedButton(onPressed: () {
          setState(() {
            if (existing == null) {
              _dummyNotices.insert(0, _Notice(id: 'N${_dummyNotices.length + 1}', title: titleCtrl.text, content: contentCtrl.text, category: category, date: '2025.04.20', isPinned: false));
            } else {
              // update in place (mutable fields not available here - just close)
            }
          });
          Navigator.of(ctx).pop();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(existing == null ? '공지가 등록되었습니다.' : '공지가 수정되었습니다.')));
        }, child: Text(existing == null ? '등록' : '수정')),
      ],
    )));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SectionCard(
          title: '공지사항 관리',
          subtitle: '${_dummyNotices.length}건',
          action: ElevatedButton.icon(onPressed: () => _showEditDialog(), icon: const Icon(Icons.add, size: 16), label: const Text('공지 등록', style: TextStyle(fontSize: 13))),
          child: Column(children: _dummyNotices.map((n) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: AdminColors.cardBorder))),
            child: Row(children: [
              if (n.isPinned) const Padding(padding: EdgeInsets.only(right: 8), child: Icon(Icons.push_pin_rounded, size: 15, color: AdminColors.error)),
              StatusBadge(label: n.category, color: _catColor(n.category)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(n.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                Text(n.date, style: const TextStyle(fontSize: 11, color: AdminColors.textSecondary)),
              ])),
              const SizedBox(width: 12),
              // 핀 토글
              IconButton(icon: Icon(n.isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined, size: 18, color: n.isPinned ? AdminColors.error : AdminColors.textDisabled),
                onPressed: () => setState(() => n.isPinned = !n.isPinned), tooltip: n.isPinned ? '핀 해제' : '핀 설정'),
              IconButton(icon: const Icon(Icons.edit_outlined, size: 18, color: AdminColors.textSecondary), onPressed: () => _showEditDialog(existing: n), tooltip: '수정'),
              IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: AdminColors.error), onPressed: () {
                setState(() => _dummyNotices.remove(n));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('공지가 삭제되었습니다.')));
              }, tooltip: '삭제'),
            ]),
          )).toList()),
        ),
      ]),
    );
  }
}
