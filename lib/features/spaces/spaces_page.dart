import 'package:flutter/material.dart';
import '../../app/theme/admin_colors.dart';
import '../../shared/widgets/stat_card.dart';

class _Space {
  _Space({required this.id, required this.title, required this.owner, required this.district, required this.category, required this.dailyRate, required this.status, required this.favorites});
  final String id, title, owner, district, category;
  final int dailyRate, favorites;
  String status;
}

final _dummySpaces = [
  _Space(id: 'S001', title: '강남 팝업 스튜디오', owner: '김민지', district: '강남구', category: '패션', dailyRate: 200000, status: 'ACTIVE', favorites: 24),
  _Space(id: 'S002', title: '홍대 크리에이티브 스페이스', owner: '최우진', district: '마포구', category: '카페', dailyRate: 150000, status: 'ACTIVE', favorites: 18),
  _Space(id: 'S003', title: '성수 컨테이너 팝업', owner: '윤소희', district: '성동구', category: '뷰티', dailyRate: 120000, status: 'ACTIVE', favorites: 32),
  _Space(id: 'S004', title: '용산 갤러리 팝업', owner: '김민지', district: '용산구', category: '페스타', dailyRate: 180000, status: 'HIDDEN', favorites: 11),
  _Space(id: 'S005', title: '종로 전통 팝업존', owner: '송예진', district: '종로구', category: '반려동물', dailyRate: 100000, status: 'ACTIVE', favorites: 7),
  _Space(id: 'S006', title: '서초 프리미엄 쇼룸', owner: '최우진', district: '서초구', category: '패션', dailyRate: 350000, status: 'ACTIVE', favorites: 45),
  _Space(id: 'S007', title: '송파 롯데타워 뷰 팝업', owner: '윤소희', district: '송파구', category: '카페', dailyRate: 280000, status: 'CLOSED', favorites: 29),
];

class SpacesPage extends StatefulWidget {
  const SpacesPage({super.key});
  @override
  State<SpacesPage> createState() => _SpacesPageState();
}

class _SpacesPageState extends State<SpacesPage> {
  String _filterStatus = '전체';
  String _search = '';

  List<_Space> get _filtered => _dummySpaces.where((s) {
    if (_filterStatus != '전체' && s.status != _filterStatus) return false;
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      if (!s.title.contains(q) && !s.district.contains(q)) return false;
    }
    return true;
  }).toList();

  Color _statusColor(String s) => switch (s) { 'ACTIVE' => AdminColors.success, 'HIDDEN' => AdminColors.warning, _ => AdminColors.textDisabled };
  String _statusLabel(String s) => switch (s) { 'ACTIVE' => '오픈', 'HIDDEN' => '숨김', _ => '종료' };

  String _formatRate(int r) => r.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  @override
  Widget build(BuildContext context) {
    final active = _dummySpaces.where((s) => s.status == 'ACTIVE').length;
    final hidden = _dummySpaces.where((s) => s.status == 'HIDDEN').length;
    final closed = _dummySpaces.where((s) => s.status == 'CLOSED').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          _SpaceStatCard(label: '전체 공간', value: '${_dummySpaces.length}', color: AdminColors.primary, icon: Icons.storefront_rounded),
          const SizedBox(width: 12),
          _SpaceStatCard(label: '오픈', value: '$active', color: AdminColors.success, icon: Icons.check_circle_rounded),
          const SizedBox(width: 12),
          _SpaceStatCard(label: '숨김', value: '$hidden', color: AdminColors.warning, icon: Icons.visibility_off_rounded),
          const SizedBox(width: 12),
          _SpaceStatCard(label: '종료', value: '$closed', color: AdminColors.textSecondary, icon: Icons.block_rounded),
        ]),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AdminColors.cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AdminColors.cardBorder)),
          child: Row(children: [
            Expanded(flex: 2, child: SizedBox(height: 40, child: TextField(onChanged: (v) => setState(() => _search = v), decoration: const InputDecoration(hintText: '공간명 또는 지역 검색', prefixIcon: Icon(Icons.search_rounded, size: 18), contentPadding: EdgeInsets.symmetric(vertical: 0))))),
            const SizedBox(width: 12),
            _FilterDrop(value: _filterStatus, items: const ['전체', 'ACTIVE', 'HIDDEN', 'CLOSED'], onChanged: (v) => setState(() => _filterStatus = v!), hint: '상태'),
          ]),
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: '공간 목록',
          subtitle: '${_filtered.length}개',
          child: Table(
            columnWidths: const {0: FixedColumnWidth(70), 1: FlexColumnWidth(2), 2: FlexColumnWidth(1.2), 3: FlexColumnWidth(1), 4: FlexColumnWidth(1), 5: FlexColumnWidth(1.2), 6: FixedColumnWidth(60), 7: FlexColumnWidth(1)},
            children: [
              _headerRow(['ID', '공간명', '등록자', '지역', '카테고리', '일 임대료', '찜', '상태']),
              ..._filtered.map((s) => TableRow(
                decoration: const BoxDecoration(border: Border(top: BorderSide(color: AdminColors.cardBorder))),
                children: [
                  _TCell(Text(s.id, style: const TextStyle(fontSize: 11, color: AdminColors.textSecondary))),
                  _TCell(Text(s.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  _TCell(Text(s.owner, style: const TextStyle(fontSize: 12))),
                  _TCell(Text(s.district, style: const TextStyle(fontSize: 12, color: AdminColors.textSecondary))),
                  _TCell(Text(s.category, style: const TextStyle(fontSize: 12))),
                  _TCell(Text('₩${_formatRate(s.dailyRate)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AdminColors.primary))),
                  _TCell(Row(children: [const Icon(Icons.favorite_rounded, size: 13, color: AdminColors.secondary), const SizedBox(width: 3), Text('${s.favorites}', style: const TextStyle(fontSize: 12))])),
                  _TCell(GestureDetector(
                    onTap: () => _showStatusMenu(s),
                    child: StatusBadge(label: _statusLabel(s.status), color: _statusColor(s.status)),
                  )),
                ],
              )),
            ],
          ),
        ),
      ]),
    );
  }

  void _showStatusMenu(_Space space) {
    showDialog<void>(context: context, builder: (ctx) => AlertDialog(
      title: Text('상태 변경 - ${space.title}'),
      content: Column(mainAxisSize: MainAxisSize.min, children: ['ACTIVE', 'HIDDEN', 'CLOSED'].map((s) {
        final color = _statusColor(s);
        return ListTile(
          leading: StatusBadge(label: _statusLabel(s), color: color),
          onTap: () { setState(() => space.status = s); Navigator.of(ctx).pop(); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('상태가 ${_statusLabel(s)}로 변경되었습니다.'))); },
        );
      }).toList()),
    ));
  }

  TableRow _headerRow(List<String> cells) => TableRow(
    decoration: const BoxDecoration(color: AdminColors.contentBg),
    children: cells.map((c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), child: Text(c, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AdminColors.textSecondary)))).toList(),
  );
}

class _TCell extends StatelessWidget {
  const _TCell(this.child);
  final Widget child;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), child: child);
}

class _FilterDrop extends StatelessWidget {
  const _FilterDrop({required this.value, required this.items, required this.onChanged, required this.hint});
  final String value; final List<String> items; final void Function(String?) onChanged; final String hint;
  @override
  Widget build(BuildContext context) => Container(
    height: 40, padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(color: AdminColors.cardBg, borderRadius: BorderRadius.circular(8), border: Border.all(color: AdminColors.cardBorder)),
    child: DropdownButton<String>(value: value, onChanged: onChanged, underline: const SizedBox.shrink(), isDense: true,
      style: const TextStyle(fontSize: 13, color: AdminColors.textPrimary),
      items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList()),
  );
}

class _SpaceStatCard extends StatelessWidget {
  const _SpaceStatCard({required this.label, required this.value, required this.color, required this.icon});
  final String label, value; final Color color; final IconData icon;
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AdminColors.cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AdminColors.cardBorder)),
    child: Row(children: [
      Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 20, color: color)),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AdminColors.textPrimary)),
        Text(label, style: const TextStyle(fontSize: 11, color: AdminColors.textSecondary)),
      ]),
    ]),
  ));
}
