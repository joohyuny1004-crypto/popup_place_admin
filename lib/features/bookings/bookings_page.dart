import 'package:flutter/material.dart';
import '../../app/theme/admin_colors.dart';
import '../../shared/widgets/stat_card.dart';

class _Booking {
  _Booking({required this.id, required this.userName, required this.spaceName, required this.district, required this.startDate, required this.endDate, required this.amount, required this.status, required this.method});
  final String id, userName, spaceName, district, startDate, endDate, method;
  final int amount;
  String status;
}

final _dummyBookings = [
  _Booking(id: 'BK-001', userName: '홍길동', spaceName: '강남 팝업 스튜디오', district: '강남구', startDate: '04.20', endDate: '04.23', amount: 600000, status: 'PENDING', method: '토스페이'),
  _Booking(id: 'BK-002', userName: '이서준', spaceName: '홍대 크리에이티브', district: '마포구', startDate: '04.18', endDate: '04.20', amount: 300000, status: 'APPROVED', method: '카카오페이'),
  _Booking(id: 'BK-003', userName: '박지영', spaceName: '서초 프리미엄 쇼룸', district: '서초구', startDate: '04.17', endDate: '04.19', amount: 700000, status: 'PENDING', method: '토스페이'),
  _Booking(id: 'BK-004', userName: '정다은', spaceName: '성수 컨테이너 팝업', district: '성동구', startDate: '04.15', endDate: '04.18', amount: 360000, status: 'REJECTED', method: '계좌이체'),
  _Booking(id: 'BK-005', userName: '최우진', spaceName: '송파 롯데타워 뷰', district: '송파구', startDate: '04.10', endDate: '04.12', amount: 560000, status: 'COMPLETED', method: '카카오페이'),
  _Booking(id: 'BK-006', userName: '임재원', spaceName: '용산 갤러리 팝업', district: '용산구', startDate: '04.22', endDate: '04.25', amount: 540000, status: 'PENDING', method: '토스페이'),
];

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});
  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  String _filterStatus = '전체';

  List<_Booking> get _filtered => _filterStatus == '전체' ? _dummyBookings : _dummyBookings.where((b) => b.status == _filterStatus).toList();

  Color _statusColor(String s) => switch (s) { 'PENDING' => AdminColors.warning, 'APPROVED' => AdminColors.success, 'REJECTED' => AdminColors.error, 'COMPLETED' => AdminColors.info, _ => AdminColors.textDisabled };
  String _statusLabel(String s) => switch (s) { 'PENDING' => '대기', 'APPROVED' => '승인', 'REJECTED' => '거절', 'COMPLETED' => '완료', _ => s };
  String _formatAmount(int a) => a.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  @override
  Widget build(BuildContext context) {
    final pending = _dummyBookings.where((b) => b.status == 'PENDING').length;
    final approved = _dummyBookings.where((b) => b.status == 'APPROVED').length;
    final total = _dummyBookings.fold(0, (s, b) => s + b.amount);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          _BkStatCard(label: '전체 예약', value: '${_dummyBookings.length}건', color: AdminColors.primary, icon: Icons.receipt_long_rounded),
          const SizedBox(width: 12),
          _BkStatCard(label: '승인 대기', value: '$pending건', color: AdminColors.warning, icon: Icons.pending_rounded),
          const SizedBox(width: 12),
          _BkStatCard(label: '승인 완료', value: '$approved건', color: AdminColors.success, icon: Icons.check_circle_rounded),
          const SizedBox(width: 12),
          _BkStatCard(label: '총 결제', value: '₩${_formatAmount(total)}', color: AdminColors.info, icon: Icons.payments_rounded),
        ]),
        const SizedBox(height: 20),
        Row(children: ['전체', 'PENDING', 'APPROVED', 'REJECTED', 'COMPLETED'].map((s) {
          final sel = _filterStatus == s;
          final label = s == '전체' ? '전체' : _statusLabel(s);
          return Padding(padding: const EdgeInsets.only(right: 8), child: FilterChip(
            label: Text(label), selected: sel,
            onSelected: (_) => setState(() => _filterStatus = s),
            selectedColor: AdminColors.primary, showCheckmark: false,
            labelStyle: TextStyle(color: sel ? Colors.white : AdminColors.textSecondary, fontWeight: sel ? FontWeight.w700 : FontWeight.w400, fontSize: 12),
            side: BorderSide(color: sel ? AdminColors.primary : AdminColors.cardBorder),
            backgroundColor: AdminColors.cardBg,
          ));
        }).toList()),
        const SizedBox(height: 16),
        SectionCard(
          title: '예약 목록',
          subtitle: '${_filtered.length}건',
          child: Column(children: _filtered.map((b) => Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: AdminColors.cardBorder))),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(b.id, style: const TextStyle(fontSize: 11, color: AdminColors.primary, fontWeight: FontWeight.w500)),
                  const SizedBox(width: 8),
                  StatusBadge(label: _statusLabel(b.status), color: _statusColor(b.status)),
                ]),
                const SizedBox(height: 6),
                Text(b.spaceName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                Text('${b.district} · ${b.startDate} ~ ${b.endDate} · ${b.userName}', style: const TextStyle(fontSize: 11, color: AdminColors.textSecondary)),
              ])),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('₩${_formatAmount(b.amount)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AdminColors.primary)),
                Text(b.method, style: const TextStyle(fontSize: 11, color: AdminColors.textSecondary)),
              ]),
              if (b.status == 'PENDING') ...[
                const SizedBox(width: 12),
                Row(children: [
                  OutlinedButton(onPressed: () => setState(() => b.status = 'REJECTED'),
                    style: OutlinedButton.styleFrom(foregroundColor: AdminColors.error, side: const BorderSide(color: AdminColors.error), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
                    child: const Text('거절', style: TextStyle(fontSize: 12))),
                  const SizedBox(width: 8),
                  ElevatedButton(onPressed: () => setState(() => b.status = 'APPROVED'),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
                    child: const Text('승인', style: TextStyle(fontSize: 12))),
                ]),
              ],
            ]),
          )).toList()),
        ),
      ]),
    );
  }
}

class _BkStatCard extends StatelessWidget {
  const _BkStatCard({required this.label, required this.value, required this.color, required this.icon});
  final String label, value; final Color color; final IconData icon;
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AdminColors.cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AdminColors.cardBorder)),
    child: Row(children: [
      Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 20, color: color)),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AdminColors.textPrimary)),
        Text(label, style: const TextStyle(fontSize: 11, color: AdminColors.textSecondary)),
      ]),
    ]),
  ));
}
