import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/admin_colors.dart';

class AdminShell extends StatelessWidget {
  const AdminShell({
    super.key,
    required this.child,
    required this.currentPath,
  });

  final Widget child;
  final String currentPath;

  static const _navItems = [
    _NavItem(icon: Icons.dashboard_rounded, label: '대시보드', path: '/'),
    _NavItem(icon: Icons.people_rounded, label: '사용자 관리', path: '/users'),
    _NavItem(icon: Icons.storefront_rounded, label: '공간 관리', path: '/spaces'),
    _NavItem(icon: Icons.receipt_long_rounded, label: '예약 관리', path: '/bookings'),
    _NavItem(icon: Icons.chat_bubble_outline_rounded, label: '고객 문의', path: '/support'),
    _NavItem(icon: Icons.campaign_rounded, label: '공지사항', path: '/notices'),
    _NavItem(icon: Icons.bar_chart_rounded, label: '통계', path: '/statistics'),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 1024;

    return Scaffold(
      backgroundColor: AdminColors.contentBg,
      body: Row(
        children: [
          // ── 사이드바 ──────────────────────────────────
          _Sidebar(
            currentPath: currentPath,
            navItems: _navItems,
            isCompact: isCompact,
          ),
          // ── 메인 콘텐츠 ───────────────────────────────
          Expanded(
            child: Column(
              children: [
                // 상단 헤더
                _TopHeader(currentPath: currentPath, navItems: _navItems),
                // 페이지 내용
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.currentPath,
    required this.navItems,
    required this.isCompact,
  });

  final String currentPath;
  final List<_NavItem> navItems;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final width = isCompact ? 64.0 : 240.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: width,
      color: AdminColors.sidebarBg,
      child: Column(
        children: [
          // 로고
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: isCompact
                ? const Center(
                    child: Icon(Icons.store_rounded,
                        color: AdminColors.sidebarIndicator, size: 28),
                  )
                : Row(
                    children: [
                      const Icon(Icons.store_rounded,
                          color: AdminColors.sidebarIndicator, size: 24),
                      const SizedBox(width: 10),
                      const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'POPUP PLACE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            'Admin Dashboard',
                            style: TextStyle(
                              color: AdminColors.sidebarText,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
          const Divider(color: AdminColors.sidebarBorder, height: 1),
          const SizedBox(height: 8),

          // 메뉴 아이템
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              itemCount: navItems.length,
              itemBuilder: (_, i) {
                final item = navItems[i];
                final isActive = currentPath == item.path ||
                    (item.path != '/' &&
                        currentPath.startsWith(item.path));
                return _SidebarItem(
                  item: item,
                  isActive: isActive,
                  isCompact: isCompact,
                  onTap: () => context.go(item.path),
                );
              },
            ),
          ),

          // 하단 어드민 정보
          const Divider(color: AdminColors.sidebarBorder, height: 1),
          Container(
            padding: const EdgeInsets.all(12),
            child: isCompact
                ? const Icon(Icons.manage_accounts_rounded,
                    color: AdminColors.sidebarText, size: 22)
                : Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: AdminColors.sidebarIndicator,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person_rounded,
                            color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '관리자',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'admin@popupplace.kr',
                            style: TextStyle(
                              color: AdminColors.sidebarText,
                              fontSize: 10,
                            ),
                          ),
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

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.item,
    required this.isActive,
    required this.isCompact,
    required this.onTap,
  });

  final _NavItem item;
  final bool isActive;
  final bool isCompact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: isCompact ? item.label : '',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 0 : 12,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: isActive
                ? AdminColors.sidebarIndicator.withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: isCompact
              ? Center(
                  child: Icon(
                    item.icon,
                    size: 22,
                    color: isActive
                        ? AdminColors.sidebarIndicator
                        : AdminColors.sidebarText,
                  ),
                )
              : Row(
                  children: [
                    if (isActive)
                      Container(
                        width: 3,
                        height: 20,
                        margin: const EdgeInsets.only(right: 9),
                        decoration: BoxDecoration(
                          color: AdminColors.sidebarIndicator,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      )
                    else
                      const SizedBox(width: 12),
                    Icon(
                      item.icon,
                      size: 18,
                      color: isActive
                          ? AdminColors.sidebarIndicator
                          : AdminColors.sidebarText,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      item.label,
                      style: TextStyle(
                        color: isActive
                            ? Colors.white
                            : AdminColors.sidebarText,
                        fontSize: 13,
                        fontWeight: isActive
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _TopHeader extends StatelessWidget {
  const _TopHeader({
    required this.currentPath,
    required this.navItems,
  });

  final String currentPath;
  final List<_NavItem> navItems;

  String get _title {
    final item = navItems.firstWhere(
      (n) =>
          n.path == currentPath ||
          (n.path != '/' && currentPath.startsWith(n.path)),
      orElse: () => navItems.first,
    );
    return item.label;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AdminColors.cardBg,
        border: Border(
          bottom: BorderSide(color: AdminColors.cardBorder),
        ),
      ),
      child: Row(
        children: [
          Text(
            _title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AdminColors.textPrimary,
            ),
          ),
          const Spacer(),
          // 알림
          _HeaderIconButton(
            icon: Icons.notifications_outlined,
            badge: '3',
            onTap: () {},
          ),
          const SizedBox(width: 8),
          // 설정
          _HeaderIconButton(
            icon: Icons.settings_outlined,
            onTap: () {},
          ),
          const SizedBox(width: 16),
          // 날짜
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AdminColors.contentBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AdminColors.cardBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded,
                    size: 14, color: AdminColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  _todayString(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AdminColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _todayString() {
    final now = DateTime.now();
    return '${now.year}.${now.month.toString().padLeft(2, '0')}.${now.day.toString().padLeft(2, '0')}';
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AdminColors.contentBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AdminColors.cardBorder),
            ),
            child: Icon(icon,
                size: 18, color: AdminColors.textSecondary),
          ),
          if (badge != null)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: AdminColors.error,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}


class _NavItem {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.path,
  });

  final IconData icon;
  final String label;
  final String path;
}
