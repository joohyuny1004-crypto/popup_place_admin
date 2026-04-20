import 'package:flutter/material.dart';

import '../../app/theme/admin_colors.dart';
import '../../shared/widgets/stat_card.dart';

class _User {
  const _User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.joinDate,
    required this.bookingCount,
    required this.status,
  });
  final String id;
  final String name;
  final String email;
  final String role;
  final String joinDate;
  final int bookingCount;
  final String status;
}

const _dummyUsers = [
  _User(id: 'U001', name: '홍길동', email: 'hong@example.com', role: 'OPERATOR', joinDate: '2025.03.10', bookingCount: 5, status: 'ACTIVE'),
  _User(id: 'U002', name: '김민지', email: 'kim@example.com', role: 'LANDLORD', joinDate: '2025.03.15', bookingCount: 0, status: 'ACTIVE'),
  _User(id: 'U003', name: '이서준', email: 'lee@example.com', role: 'OPERATOR', joinDate: '2025.03.20', bookingCount: 12, status: 'ACTIVE'),
  _User(id: 'U004', name: '박지영', email: 'park@example.com', role: 'OPERATOR', joinDate: '2025.03.22', bookingCount: 3, status: 'ACTIVE'),
  _User(id: 'U005', name: '최우진', email: 'choi@example.com', role: 'LANDLORD', joinDate: '2025.04.01', bookingCount: 0, status: 'ACTIVE'),
  _User(id: 'U006', name: '정다은', email: 'jung@example.com', role: 'OPERATOR', joinDate: '2025.04.05', bookingCount: 7, status: 'ACTIVE'),
  _User(id: 'U007', name: '강현수', email: 'kang@example.com', role: 'OPERATOR', joinDate: '2025.04.08', bookingCount: 1, status: 'SUSPENDED'),
  _User(id: 'U008', name: '윤소희', email: 'yoon@example.com', role: 'LANDLORD', joinDate: '2025.04.10', bookingCount: 0, status: 'ACTIVE'),
  _User(id: 'U009', name: '임재원', email: 'lim@example.com', role: 'OPERATOR', joinDate: '2025.04.12', bookingCount: 2, status: 'ACTIVE'),
  _User(id: 'U010', name: '송예진', email: 'song@example.com', role: 'LANDLORD', joinDate: '2025.04.15', bookingCount: 0, status: 'ACTIVE'),
];

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  String _filterRole = '전체';
  String _filterStatus = '전체';
  String _search = '';

  List<_User> get _filtered => _dummyUsers.where((u) {
        if (_filterRole != '전체') {
          final roleEn = _filterRole == '운영자' ? 'OPERATOR' : 'LANDLORD';
          if (u.role != roleEn) return false;
        }
        if (_filterStatus != '전체' && u.status != _filterStatus) return false;
        if (_search.isNotEmpty) {
          final q = _search.toLowerCase();
          if (!u.name.contains(q) && !u.email.contains(q)) return false;
        }
        return true;
      }).toList();

  @override
  Widget build(BuildContext context) {
    final operatorCount = _dummyUsers.where((u) => u.role == 'OPERATOR').length;
    final landlordCount = _dummyUsers.where((u) => u.role == 'LANDLORD').length;
    final activeCount = _dummyUsers.where((u) => u.status == 'ACTIVE').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 요약 카드
          Row(
            children: [
              _SmallStatCard(
                label: '전체 사용자',
                value: '${_dummyUsers.length}',
                icon: Icons.people_rounded,
                color: AdminColors.primary,
              ),
              const SizedBox(width: 12),
              _SmallStatCard(
                label: '팝업 운영자',
                value: '$operatorCount',
                icon: Icons.storefront_rounded,
                color: AdminColors.info,
              ),
              const SizedBox(width: 12),
              _SmallStatCard(
                label: '공간 제공자',
                value: '$landlordCount',
                icon: Icons.house_rounded,
                color: AdminColors.secondary,
              ),
              const SizedBox(width: 12),
              _SmallStatCard(
                label: '활성 계정',
                value: '$activeCount',
                icon: Icons.check_circle_rounded,
                color: AdminColors.success,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 필터 + 검색
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AdminColors.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AdminColors.cardBorder),
            ),
            child: Row(
              children: [
                // 검색
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 40,
                    child: TextField(
                      onChanged: (v) => setState(() => _search = v),
                      decoration: const InputDecoration(
                        hintText: '이름 또는 이메일 검색',
                        prefixIcon: Icon(Icons.search_rounded, size: 18),
                        contentPadding: EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // 역할 필터
                _FilterDropdown(
                  value: _filterRole,
                  items: const ['전체', '운영자', '공간 제공자'],
                  onChanged: (v) => setState(() => _filterRole = v!),
                  hint: '역할',
                ),
                const SizedBox(width: 8),
                // 상태 필터
                _FilterDropdown(
                  value: _filterStatus,
                  items: const ['전체', 'ACTIVE', 'SUSPENDED'],
                  onChanged: (v) => setState(() => _filterStatus = v!),
                  hint: '상태',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 사용자 테이블
          SectionCard(
            title: '사용자 목록',
            subtitle: '${_filtered.length}명',
            child: _UsersTable(users: _filtered),
          ),
        ],
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
    required this.hint,
  });

  final String value;
  final List<String> items;
  final void Function(String?) onChanged;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AdminColors.cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AdminColors.cardBorder),
      ),
      child: DropdownButton<String>(
        value: value,
        onChanged: onChanged,
        underline: const SizedBox.shrink(),
        isDense: true,
        style: const TextStyle(
          fontSize: 13,
          color: AdminColors.textPrimary,
        ),
        items: items
            .map((i) => DropdownMenuItem(value: i, child: Text(i)))
            .toList(),
      ),
    );
  }
}

class _UsersTable extends StatelessWidget {
  const _UsersTable({required this.users});
  final List<_User> users;

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: const {
        0: FixedColumnWidth(80),
        1: FlexColumnWidth(1.5),
        2: FlexColumnWidth(2),
        3: FlexColumnWidth(1),
        4: FlexColumnWidth(1.2),
        5: FixedColumnWidth(60),
        6: FlexColumnWidth(1),
      },
      children: [
        // 헤더
        _tableRow(
          isHeader: true,
          cells: ['ID', '이름', '이메일', '역할', '가입일', '예약수', '상태'],
        ),
        ...users.map((u) {
          final roleColor =
              u.role == 'OPERATOR' ? AdminColors.info : AdminColors.secondary;
          final roleLabel =
              u.role == 'OPERATOR' ? '운영자' : '제공자';
          final statusColor =
              u.status == 'ACTIVE' ? AdminColors.success : AdminColors.error;
          final statusLabel =
              u.status == 'ACTIVE' ? '활성' : '정지';

          return TableRow(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AdminColors.cardBorder)),
            ),
            children: [
              _TCell(Text(u.id,
                  style: const TextStyle(
                      fontSize: 11, color: AdminColors.textSecondary))),
              _TCell(Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: roleColor.withOpacity(0.12),
                    child: Text(u.name[0],
                        style: TextStyle(
                            color: roleColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 12)),
                  ),
                  const SizedBox(width: 8),
                  Text(u.name,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500)),
                ],
              )),
              _TCell(Text(u.email,
                  style: const TextStyle(
                      fontSize: 12, color: AdminColors.textSecondary))),
              _TCell(StatusBadge(label: roleLabel, color: roleColor)),
              _TCell(Text(u.joinDate,
                  style: const TextStyle(
                      fontSize: 12, color: AdminColors.textSecondary))),
              _TCell(Text('${u.bookingCount}',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600))),
              _TCell(StatusBadge(label: statusLabel, color: statusColor)),
            ],
          );
        }),
      ],
    );
  }

  TableRow _tableRow({
    required bool isHeader,
    required List<String> cells,
  }) {
    return TableRow(
      decoration: isHeader
          ? const BoxDecoration(color: AdminColors.contentBg)
          : null,
      children: cells
          .map((c) => Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                child: Text(
                  c,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AdminColors.textSecondary,
                  ),
                ),
              ))
          .toList(),
    );
  }
}

class _TCell extends StatelessWidget {
  const _TCell(this.child);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: child,
    );
  }
}

class _SmallStatCard extends StatelessWidget {
  const _SmallStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

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
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AdminColors.textPrimary,
                    )),
                Text(label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AdminColors.textSecondary,
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
