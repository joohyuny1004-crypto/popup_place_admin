import 'package:flutter/material.dart';

import '../../app/theme/admin_colors.dart';
import '../../shared/widgets/stat_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  // ── 더미 데이터 ────────────────────────────────────────
  static const _weeklyBookings = [12, 19, 8, 24, 31, 27, 18];
  static const _weekDays = ['월', '화', '수', '목', '금', '토', '일'];

  static const _categoryData = [
    ('패션', 0.32, AdminColors.primary),
    ('카페', 0.25, Color(0xFF10B981)),
    ('뷰티', 0.18, AdminColors.secondary),
    ('페스타', 0.15, AdminColors.warning),
    ('반려동물', 0.10, AdminColors.info),
  ];

  static const _recentBookings = [
    ('BK-2025041801', '홍길동', '강남 팝업 스튜디오', '2025.04.18', '대기'),
    ('BK-2025041802', '김민지', '홍대 크리에이티브', '2025.04.18', '승인'),
    ('BK-2025041803', '이서준', '서초 프리미엄 쇼룸', '2025.04.17', '대기'),
    ('BK-2025041804', '박지영', '성수 컨테이너 팝업', '2025.04.17', '거절'),
    ('BK-2025041805', '최우진', '송파 롯데타워 뷰', '2025.04.16', '승인'),
  ];

  static const _recentUsers = [
    ('홍길동', 'hong@example.com', '팝업 운영자', '2025.04.18'),
    ('김민지', 'kim@example.com', '공간 제공자', '2025.04.17'),
    ('이서준', 'lee@example.com', '팝업 운영자', '2025.04.16'),
    ('박지영', 'park@example.com', '팝업 운영자', '2025.04.15'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── KPI 카드 4개 ──────────────────────────────
          LayoutBuilder(builder: (context, constraints) {
            final cols = constraints.maxWidth > 900 ? 4 : 2;
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: cols,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.6,
              children: const [
                KpiCard(
                  title: '총 사용자',
                  value: '1,247',
                  subtitle: '이번 달 +84명 신규가입',
                  icon: Icons.people_rounded,
                  gradientColors: [AdminColors.kpi1Start, AdminColors.kpi1End],
                  trend: '+7.2%',
                  trendUp: true,
                ),
                KpiCard(
                  title: '활성 공간',
                  value: '89',
                  subtitle: '전체 공간 104개 중',
                  icon: Icons.storefront_rounded,
                  gradientColors: [AdminColors.kpi2Start, AdminColors.kpi2End],
                  trend: '+12%',
                  trendUp: true,
                ),
                KpiCard(
                  title: '이번 달 예약',
                  value: '158',
                  subtitle: '전월 대비 +23건',
                  icon: Icons.receipt_long_rounded,
                  gradientColors: [AdminColors.kpi3Start, AdminColors.kpi3End],
                  trend: '+17%',
                  trendUp: true,
                ),
                KpiCard(
                  title: '월 매출',
                  value: '₩47.8M',
                  subtitle: '결제 완료 기준',
                  icon: Icons.payments_rounded,
                  gradientColors: [AdminColors.kpi4Start, AdminColors.kpi4End],
                  trend: '+9.4%',
                  trendUp: true,
                ),
              ],
            );
          }),
          const SizedBox(height: 24),

          // ── 차트 행 ───────────────────────────────────
          LayoutBuilder(builder: (context, constraints) {
            final isWide = constraints.maxWidth > 900;
            return isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          flex: 3,
                          child: _WeeklyBookingsChart(
                            bookings: _weeklyBookings,
                            days: _weekDays,
                          )),
                      const SizedBox(width: 16),
                      Expanded(
                          flex: 2,
                          child: _CategoryChart(data: _categoryData)),
                    ],
                  )
                : Column(
                    children: [
                      _WeeklyBookingsChart(
                        bookings: _weeklyBookings,
                        days: _weekDays,
                      ),
                      const SizedBox(height: 16),
                      _CategoryChart(data: _categoryData),
                    ],
                  );
          }),
          const SizedBox(height: 24),

          // ── 최근 예약 + 신규 사용자 ───────────────────
          LayoutBuilder(builder: (context, constraints) {
            final isWide = constraints.maxWidth > 900;
            return isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          flex: 3,
                          child:
                              _RecentBookingsTable(bookings: _recentBookings)),
                      const SizedBox(width: 16),
                      Expanded(
                          flex: 2,
                          child: _RecentUsersCard(users: _recentUsers)),
                    ],
                  )
                : Column(
                    children: [
                      _RecentBookingsTable(bookings: _recentBookings),
                      const SizedBox(height: 16),
                      _RecentUsersCard(users: _recentUsers),
                    ],
                  );
          }),
        ],
      ),
    );
  }
}

// ── 주간 예약 막대 차트 ────────────────────────────────────

class _WeeklyBookingsChart extends StatelessWidget {
  const _WeeklyBookingsChart({
    required this.bookings,
    required this.days,
  });

  final List<int> bookings;
  final List<String> days;

  @override
  Widget build(BuildContext context) {
    final maxVal = bookings.reduce((a, b) => a > b ? a : b).toDouble();
    return SectionCard(
      title: '주간 예약 현황',
      subtitle: '최근 7일',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: SizedBox(
          height: 180,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(bookings.length, (i) {
              final ratio = bookings[i] / maxVal;
              final isToday = i == bookings.length - 1;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${bookings[i]}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isToday
                              ? AdminColors.primary
                              : AdminColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedContainer(
                        duration: Duration(milliseconds: 400 + i * 60),
                        curve: Curves.easeOut,
                        height: ratio * 130,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: isToday
                                ? [AdminColors.primary, const Color(0xFF818CF8)]
                                : [
                                    AdminColors.primary.withOpacity(0.25),
                                    AdminColors.primary.withOpacity(0.45),
                                  ],
                          ),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        days[i],
                        style: TextStyle(
                          fontSize: 11,
                          color: isToday
                              ? AdminColors.primary
                              : AdminColors.textSecondary,
                          fontWeight: isToday
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ── 카테고리 도넛 차트 ────────────────────────────────────

class _CategoryChart extends StatelessWidget {
  const _CategoryChart({required this.data});

  final List<(String, double, Color)> data;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: '카테고리 분포',
      subtitle: '전체 공간 기준',
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 간단한 가로 비율 바
            ...data.map((item) {
              final (label, ratio, color) = item;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          label,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AdminColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${(ratio * 100).round()}%',
                          style: TextStyle(
                            fontSize: 12,
                            color: color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: ratio,
                        minHeight: 8,
                        backgroundColor: color.withOpacity(0.12),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ── 최근 예약 테이블 ──────────────────────────────────────

class _RecentBookingsTable extends StatelessWidget {
  const _RecentBookingsTable({required this.bookings});

  final List<(String, String, String, String, String)> bookings;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: '최근 예약',
      action: TextButton(
        onPressed: () {},
        child: const Text('전체 보기',
            style: TextStyle(
              fontSize: 12,
              color: AdminColors.primary,
            )),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1.5),
          1: FlexColumnWidth(1),
          2: FlexColumnWidth(2),
          3: FlexColumnWidth(1.2),
          4: FlexColumnWidth(1),
        },
        children: [
          // 헤더
          TableRow(
            decoration: const BoxDecoration(
              color: AdminColors.contentBg,
            ),
            children: ['예약번호', '사용자', '공간', '날짜', '상태']
                .map((h) => Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      child: Text(
                        h,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AdminColors.textSecondary,
                        ),
                      ),
                    ))
                .toList(),
          ),
          ...bookings.map((b) {
            final (id, user, space, date, status) = b;
            final statusColor = switch (status) {
              '승인' => AdminColors.success,
              '거절' => AdminColors.error,
              _ => AdminColors.warning,
            };
            return TableRow(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AdminColors.cardBorder),
                ),
              ),
              children: [
                _TCell(
                    Text(id,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AdminColors.primary,
                          fontWeight: FontWeight.w500,
                        ))),
                _TCell(Text(user,
                    style:
                        const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
                _TCell(Text(space,
                    style: const TextStyle(
                        fontSize: 12, color: AdminColors.textSecondary),
                    maxLines: 1)),
                _TCell(Text(date,
                    style: const TextStyle(
                        fontSize: 11, color: AdminColors.textSecondary))),
                _TCell(StatusBadge(label: status, color: statusColor)),
              ],
            );
          }),
        ],
      ),
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

// ── 신규 사용자 카드 ──────────────────────────────────────

class _RecentUsersCard extends StatelessWidget {
  const _RecentUsersCard({required this.users});

  final List<(String, String, String, String)> users;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: '신규 사용자',
      action: TextButton(
        onPressed: () {},
        child: const Text('전체 보기',
            style: TextStyle(fontSize: 12, color: AdminColors.primary)),
      ),
      child: Column(
        children: users.map((u) {
          final (name, email, role, date) = u;
          final isOp = role == '팝업 운영자';
          return Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(
                  top: BorderSide(color: AdminColors.cardBorder)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: isOp
                      ? AdminColors.primaryLight
                      : AdminColors.secondaryLight,
                  child: Text(
                    name[0],
                    style: TextStyle(
                      color:
                          isOp ? AdminColors.primary : AdminColors.secondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AdminColors.textPrimary,
                          )),
                      Text(email,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AdminColors.textSecondary,
                          )),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    StatusBadge(
                      label: role == '팝업 운영자' ? 'OP' : 'LL',
                      color: isOp ? AdminColors.info : AdminColors.secondary,
                    ),
                    const SizedBox(height: 2),
                    Text(date,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AdminColors.textDisabled,
                        )),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
