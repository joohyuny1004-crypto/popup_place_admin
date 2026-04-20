import 'package:flutter/material.dart';

import '../../app/theme/admin_colors.dart';
import '../../shared/widgets/stat_card.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  String _period = '월간';

  static const _monthlyRevenue = [
    ('1월', 28500000),
    ('2월', 34200000),
    ('3월', 41800000),
    ('4월', 47820000),
  ];

  static const _monthlyBookings = [
    ('1월', 98),
    ('2월', 124),
    ('3월', 139),
    ('4월', 158),
  ];

  static const _regionData = [
    ('강남구', 28, AdminColors.primary),
    ('마포구', 22, AdminColors.secondary),
    ('성동구', 18, Color(0xFF10B981)),
    ('용산구', 14, AdminColors.warning),
    ('서초구', 11, AdminColors.info),
    ('기타', 7, AdminColors.textDisabled),
  ];

  static const _categoryRevenue = [
    ('패션', 15800000, AdminColors.primary),
    ('카페', 12400000, Color(0xFF10B981)),
    ('뷰티', 9200000, AdminColors.secondary),
    ('페스타', 7100000, AdminColors.warning),
    ('반려동물', 3320000, AdminColors.info),
  ];

  static const _paymentMethods = [
    ('토스페이', 0.48, AdminColors.primary),
    ('카카오페이', 0.35, Color(0xFFF59E0B)),
    ('계좌이체', 0.17, AdminColors.textSecondary),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 기간 선택
          Row(
            children: [
              ...['주간', '월간', '연간'].map((p) {
                final selected = _period == p;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _period = p),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? AdminColors.primary
                            : AdminColors.cardBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: selected
                              ? AdminColors.primary
                              : AdminColors.cardBorder,
                        ),
                      ),
                      child: Text(
                        p,
                        style: TextStyle(
                          color: selected
                              ? Colors.white
                              : AdminColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 20),

          // KPI 요약
          LayoutBuilder(builder: (ctx, c) {
            final cols = c.maxWidth > 900 ? 4 : 2;
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: cols,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.2,
              children: const [
                _MetricTile(
                  label: '총 매출',
                  value: '₩47.8M',
                  change: '+9.4%',
                  up: true,
                  icon: Icons.payments_rounded,
                  color: AdminColors.primary,
                ),
                _MetricTile(
                  label: '총 예약',
                  value: '158건',
                  change: '+17%',
                  up: true,
                  icon: Icons.receipt_long_rounded,
                  color: AdminColors.success,
                ),
                _MetricTile(
                  label: '평균 임대료',
                  value: '₩302K',
                  change: '+3.2%',
                  up: true,
                  icon: Icons.trending_up_rounded,
                  color: AdminColors.warning,
                ),
                _MetricTile(
                  label: '재이용률',
                  value: '42%',
                  change: '+5%p',
                  up: true,
                  icon: Icons.repeat_rounded,
                  color: AdminColors.secondary,
                ),
              ],
            );
          }),
          const SizedBox(height: 20),

          // 매출 + 예약 추이
          LayoutBuilder(builder: (ctx, c) {
            final isWide = c.maxWidth > 900;
            final row1 = isWide
                ? Row(children: [
                    Expanded(child: _RevenueChart(data: _monthlyRevenue)),
                    const SizedBox(width: 16),
                    Expanded(child: _BookingsChart(data: _monthlyBookings)),
                  ])
                : Column(children: [
                    _RevenueChart(data: _monthlyRevenue),
                    const SizedBox(height: 16),
                    _BookingsChart(data: _monthlyBookings),
                  ]);
            final row2 = isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _RegionChart(data: _regionData)),
                      const SizedBox(width: 16),
                      Expanded(
                          child: _CategoryRevenue(data: _categoryRevenue)),
                      const SizedBox(width: 16),
                      Expanded(
                          child: _PaymentMethodChart(data: _paymentMethods)),
                    ],
                  )
                : Column(children: [
                    _RegionChart(data: _regionData),
                    const SizedBox(height: 16),
                    _CategoryRevenue(data: _categoryRevenue),
                    const SizedBox(height: 16),
                    _PaymentMethodChart(data: _paymentMethods),
                  ]);

            return Column(children: [
              row1,
              const SizedBox(height: 16),
              row2,
            ]);
          }),
        ],
      ),
    );
  }
}

// ── 매출 추이 ─────────────────────────────────────────────

class _RevenueChart extends StatelessWidget {
  const _RevenueChart({required this.data});
  final List<(String, int)> data;

  @override
  Widget build(BuildContext context) {
    final maxVal = data.map((d) => d.$2).reduce((a, b) => a > b ? a : b);

    return SectionCard(
      title: '월별 매출 추이',
      subtitle: '단위: 백만원',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: SizedBox(
          height: 160,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: data.map((d) {
              final ratio = d.$2 / maxVal;
              final isLatest = d == data.last;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '₩${(d.$2 / 1000000).toStringAsFixed(1)}M',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isLatest
                              ? AdminColors.primary
                              : AdminColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: ratio * 110,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: isLatest
                                ? const [AdminColors.primary, Color(0xFF818CF8)]
                                : [
                                    AdminColors.primary.withOpacity(0.2),
                                    AdminColors.primary.withOpacity(0.4),
                                  ],
                          ),
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6)),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(d.$1,
                          style: TextStyle(
                            fontSize: 11,
                            color: isLatest
                                ? AdminColors.primary
                                : AdminColors.textSecondary,
                            fontWeight: isLatest
                                ? FontWeight.w700
                                : FontWeight.w400,
                          )),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ── 예약 추이 ─────────────────────────────────────────────

class _BookingsChart extends StatelessWidget {
  const _BookingsChart({required this.data});
  final List<(String, int)> data;

  @override
  Widget build(BuildContext context) {
    final maxVal = data.map((d) => d.$2).reduce((a, b) => a > b ? a : b);

    return SectionCard(
      title: '월별 예약 건수',
      subtitle: '단위: 건',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: SizedBox(
          height: 160,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: data.map((d) {
              final ratio = d.$2 / maxVal;
              final isLatest = d == data.last;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${d.$2}건',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isLatest
                              ? AdminColors.success
                              : AdminColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: ratio * 110,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: isLatest
                                ? const [AdminColors.success, Color(0xFF34D399)]
                                : [
                                    AdminColors.success.withOpacity(0.2),
                                    AdminColors.success.withOpacity(0.4),
                                  ],
                          ),
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6)),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(d.$1,
                          style: TextStyle(
                            fontSize: 11,
                            color: isLatest
                                ? AdminColors.success
                                : AdminColors.textSecondary,
                            fontWeight: isLatest
                                ? FontWeight.w700
                                : FontWeight.w400,
                          )),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ── 지역 분포 ─────────────────────────────────────────────

class _RegionChart extends StatelessWidget {
  const _RegionChart({required this.data});
  final List<(String, int, Color)> data;

  @override
  Widget build(BuildContext context) {
    final total = data.fold(0, (s, d) => s + d.$2);
    return SectionCard(
      title: '지역별 공간 분포',
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: data.map((d) {
            final ratio = d.$2 / total;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration:
                        BoxDecoration(color: d.$3, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 44,
                    child: Text(d.$1,
                        style: const TextStyle(
                            fontSize: 12, color: AdminColors.textPrimary)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: ratio,
                        minHeight: 8,
                        backgroundColor: d.$3.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(d.$3),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 28,
                    child: Text(
                      '${d.$2}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AdminColors.textPrimary,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ── 카테고리별 매출 ───────────────────────────────────────

class _CategoryRevenue extends StatelessWidget {
  const _CategoryRevenue({required this.data});
  final List<(String, int, Color)> data;

  @override
  Widget build(BuildContext context) {
    final maxVal = data.map((d) => d.$2).reduce((a, b) => a > b ? a : b);
    return SectionCard(
      title: '카테고리별 매출',
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: data.map((d) {
            final ratio = d.$2 / maxVal;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(d.$1,
                          style: const TextStyle(
                              fontSize: 12,
                              color: AdminColors.textPrimary,
                              fontWeight: FontWeight.w500)),
                      const Spacer(),
                      Text(
                        '₩${(d.$2 / 1000000).toStringAsFixed(1)}M',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: d.$3,
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
                      backgroundColor: d.$3.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(d.$3),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ── 결제 수단 ─────────────────────────────────────────────

class _PaymentMethodChart extends StatelessWidget {
  const _PaymentMethodChart({required this.data});
  final List<(String, double, Color)> data;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: '결제 수단 비율',
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: data.map((d) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: d.$3.withOpacity(0.06),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: d.$3.withOpacity(0.15)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: d.$3.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        d.$1[0],
                        style: TextStyle(
                          color: d.$3,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(d.$1,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AdminColors.textPrimary,
                            )),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: d.$2,
                            minHeight: 6,
                            backgroundColor: d.$3.withOpacity(0.12),
                            valueColor: AlwaysStoppedAnimation<Color>(d.$3),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${(d.$2 * 100).round()}%',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: d.$3,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ── 메트릭 타일 ───────────────────────────────────────────

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.change,
    required this.up,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final String change;
  final bool up;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AdminColors.textPrimary,
                    )),
                Row(
                  children: [
                    Flexible(
                        child: Text(label,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AdminColors.textSecondary,
                            ))),
                    const SizedBox(width: 4),
                    Icon(
                      up ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                      size: 10,
                      color: up ? AdminColors.success : AdminColors.error,
                    ),
                    Text(change,
                        style: TextStyle(
                          fontSize: 10,
                          color: up ? AdminColors.success : AdminColors.error,
                          fontWeight: FontWeight.w600,
                        )),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
